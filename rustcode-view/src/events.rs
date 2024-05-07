use rustcode_core::Rope;
use rustcode_event::events;

use crate::{Document, ViewId};

events! {
    DocumentDidChange<'a> { doc: &'a mut Document, view: ViewId, old_text: &'a Rope  }
    SelectionDidChange<'a> { doc: &'a mut Document, view: ViewId }
}
