use std::cell::RefCell;

use wasm_bindgen::closure::Closure;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::{Document, Event, HtmlElement, HtmlFormElement, HtmlInputElement, Window};

#[derive(Default)]
struct AppState {
    todos: Vec<Todo>,
    next_id: usize,
}

#[derive(Clone)]
struct Todo {
    id: usize,
    text: String,
    completed: bool,
}

thread_local! {
    static STATE: RefCell<AppState> = RefCell::new(AppState::default());
}

#[wasm_bindgen(start)]
pub fn run() -> Result<(), JsValue> {
    console_error_panic_hook::set_once();
    let document = document()?;

    setup_form_listener(&document)?;
    setup_toggle_listener(&document)?;

    render(&document)?;

    Ok(())
}

fn setup_form_listener(document: &Document) -> Result<(), JsValue> {
    let form: HtmlFormElement = document
        .get_element_by_id("todo-form")
        .ok_or_else(|| JsValue::from_str("todo form not found"))?
        .dyn_into()?;

    let input: HtmlInputElement = document
        .get_element_by_id("todo-input")
        .ok_or_else(|| JsValue::from_str("todo input not found"))?
        .dyn_into()?;

    let document = document.clone();

    let closure = Closure::<dyn FnMut(Event)>::wrap(Box::new(move |event: Event| {
        event.prevent_default();

        let value = input.value().trim().to_owned();
        if value.is_empty() {
            return;
        }

        STATE.with(|state| {
            let mut state = state.borrow_mut();
            let id = state.next_id;
            state.next_id += 1;
            state.todos.push(Todo {
                id,
                text: value.clone(),
                completed: false,
            });
        });

        input.set_value("");

        if let Err(err) = render(&document) {
            web_sys::console::error_1(&err);
        }
    }) as Box<dyn FnMut(_)>);

    form.add_event_listener_with_callback("submit", closure.as_ref().unchecked_ref())?;
    closure.forget();

    Ok(())
}

fn setup_toggle_listener(document: &Document) -> Result<(), JsValue> {
    let list: HtmlElement = document
        .get_element_by_id("todo-list")
        .ok_or_else(|| JsValue::from_str("todo list not found"))?
        .dyn_into()?;

    let document = document.clone();

    let closure = Closure::<dyn FnMut(Event)>::wrap(Box::new(move |event: Event| {
        let Some(target) = event.target() else {
            return;
        };

        if let Ok(input) = target.dyn_into::<HtmlInputElement>() {
            if let Ok(id) = input
                .get_attribute("data-id")
                .unwrap_or_default()
                .parse::<usize>()
            {
                let checked = input.checked();
                STATE.with(|state| {
                    let mut state = state.borrow_mut();
                    if let Some(todo) = state.todos.iter_mut().find(|todo| todo.id == id) {
                        todo.completed = checked;
                    }
                });

                if let Err(err) = render(&document) {
                    web_sys::console::error_1(&err);
                }
            }
        }
    }) as Box<dyn FnMut(_)>);

    list.add_event_listener_with_callback("change", closure.as_ref().unchecked_ref())?;
    closure.forget();

    Ok(())
}

fn render(document: &Document) -> Result<(), JsValue> {
    let list: HtmlElement = document
        .get_element_by_id("todo-list")
        .ok_or_else(|| JsValue::from_str("todo list not found"))?
        .dyn_into()?;

    let empty_state: HtmlElement = document
        .get_element_by_id("empty-state")
        .ok_or_else(|| JsValue::from_str("empty state not found"))?
        .dyn_into()?;

    // Remove existing items
    while let Some(child) = list.first_child() {
        list.remove_child(&child)?;
    }

    STATE.with(|state| {
        let state = state.borrow();
        if state.todos.is_empty() {
            let _ = empty_state.style().set_property("display", "block");
        } else {
            let _ = empty_state.style().set_property("display", "none");
        }

        for todo in &state.todos {
            if let Err(err) = render_item(&list, todo) {
                web_sys::console::error_1(&err);
            }
        }
    });

    Ok(())
}

fn render_item(list: &HtmlElement, todo: &Todo) -> Result<(), JsValue> {
    let document = document()?;
    let li = document.create_element("li")?;
    li.set_class_name("todo-item");

    let checkbox = document
        .create_element("input")?
        .dyn_into::<HtmlInputElement>()?;
    checkbox.set_type("checkbox");
    checkbox.set_checked(todo.completed);
    checkbox.set_attribute("data-id", &todo.id.to_string())?;
    checkbox.set_class_name("todo-checkbox");

    let label = document.create_element("span")?;
    label.set_class_name("todo-label");
    label.set_text_content(Some(&todo.text));

    if todo.completed {
        label.class_list().add_1("todo-completed")?;
    }

    li.append_child(&checkbox)?;
    li.append_child(&label)?;

    list.append_child(&li)?;

    Ok(())
}

fn document() -> Result<Document, JsValue> {
    window()?
        .document()
        .ok_or_else(|| JsValue::from_str("document not available"))
}

fn window() -> Result<Window, JsValue> {
    web_sys::window().ok_or_else(|| JsValue::from_str("window not available"))
}
