#[macro_export]
macro_rules! key {
    ($key:ident) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::$key,
            modifiers: ::rustcode_view::keyboard::KeyModifiers::NONE,
        }
    };
    ($($ch:tt)*) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::Char($($ch)*),
            modifiers: ::rustcode_view::keyboard::KeyModifiers::NONE,
        }
    };
}

#[macro_export]
macro_rules! shift {
    ($key:ident) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::$key,
            modifiers: ::rustcode_view::keyboard::KeyModifiers::SHIFT,
        }
    };
    ($($ch:tt)*) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::Char($($ch)*),
            modifiers: ::rustcode_view::keyboard::KeyModifiers::SHIFT,
        }
    };
}

#[macro_export]
macro_rules! ctrl {
    ($key:ident) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::$key,
            modifiers: ::rustcode_view::keyboard::KeyModifiers::CONTROL,
        }
    };
    ($($ch:tt)*) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::Char($($ch)*),
            modifiers: ::rustcode_view::keyboard::KeyModifiers::CONTROL,
        }
    };
}

#[macro_export]
macro_rules! alt {
    ($key:ident) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::$key,
            modifiers: ::rustcode_view::keyboard::KeyModifiers::ALT,
        }
    };
    ($($ch:tt)*) => {
        ::rustcode_view::input::KeyEvent {
            code: ::rustcode_view::keyboard::KeyCode::Char($($ch)*),
            modifiers: ::rustcode_view::keyboard::KeyModifiers::ALT,
        }
    };
}

/// Macro for defining a `KeyTrie`. Example:
///
/// ```
/// # use rustcode_core::hashmap;
/// # use rustcode_term::keymap;
/// let normal_mode = keymap!({ "Normal mode"
///     "i" => insert_mode,
///     "g" => { "Goto"
///         "g" => goto_file_start,
///         "e" => goto_file_end,
///     },
///     "j" | "down" => move_line_down,
/// });
/// let keymap = normal_mode;
/// ```
#[macro_export]
macro_rules! keymap {
    (@trie $cmd:ident) => {
        $crate::keymap::KeyTrie::MappableCommand($crate::commands::MappableCommand::$cmd)
    };

    (@trie
        { $label:literal $(sticky=$sticky:literal)? $($($key:literal)|+ => $value:tt,)+ }
    ) => {
        keymap!({ $label $(sticky=$sticky)? $($($key)|+ => $value,)+ })
    };

    (@trie [$($cmd:ident),* $(,)?]) => {
        $crate::keymap::KeyTrie::Sequence(vec![$($crate::commands::Command::$cmd),*])
    };

    (
        { $label:literal $(sticky=$sticky:literal)? $($($key:literal)|+ => $value:tt,)+ }
    ) => {
        // modified from the hashmap! macro
        {
            let _cap = hashmap!(@count $($($key),+),*);
            let mut _map = ::std::collections::HashMap::with_capacity(_cap);
            let mut _order = ::std::vec::Vec::with_capacity(_cap);
            $(
                $(
                    let _key = $key.parse::<::rustcode_view::input::KeyEvent>().unwrap();
                    let _duplicate = _map.insert(
                        _key,
                        keymap!(@trie $value)
                    );
                    assert!(_duplicate.is_none(), "Duplicate key found: {:?}", _duplicate.unwrap());
                    _order.push(_key);
                )+
            )*
            let mut _node = $crate::keymap::KeyTrieNode::new($label, _map, _order);
            $( _node.is_sticky = $sticky; )?
            $crate::keymap::KeyTrie::Node(_node)
        }
    };
}

pub use alt;
pub use ctrl;
pub use key;
pub use keymap;
pub use shift;
