#[derive(Debug)]
pub struct SubscriberName(String);

use unicode_segmentation::UnicodeSegmentation;

impl SubscriberName {
    pub fn parse(s: String) -> Result<Self, String> {
        let is_empty_or_whitespace = s.trim().is_empty();
        let is_too_long = s.grapheme_indices(true).count() > 256;
        let forbidden_chars = ['/', '(', ')', '"', '\'', '<', '>', '\\', '{', '}'];
        let contains_forbidden_char = s.chars().any(|c| forbidden_chars.contains(&c));
        if is_empty_or_whitespace || is_too_long || contains_forbidden_char {
            return Err(format!("{} is not a valid subscriber name", s));
        } else {
            Ok(Self(s))
        }
    }
}

impl AsRef<str> for SubscriberName {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

#[cfg(test)]
mod tests {
    use claims::{assert_err, assert_ok};

    use crate::domain::subscriber_name::SubscriberName;

    #[test]
    fn a_256_grapheme_long_name_is_valid() {
        let name = "ê".repeat(256);
        assert_ok!(SubscriberName::parse(name));
    }
    #[test]
    fn a_257_grapheme_long_name_is_invalid() {
        let name = "ã".repeat(257);
        assert_err!(SubscriberName::parse(name));
    }
    #[test]
    fn white_only_names_are_rejected() {
        let name = " ".to_string();
        assert_err!(SubscriberName::parse(name));
    }
    #[test]
    fn empty_string_is_rejected() {
        let name = "".to_string();
        assert_err!(SubscriberName::parse(name));
    }

    #[test]
    fn names_containing_an_invalid_character_are_rejected() {
        for name in &['/', '(', ')', '"', '\'', '<', '>', '\\', '{', '}'] {
            let name = name.to_string();
            assert_err!(SubscriberName::parse(name));
        }
    }

    #[test]
    fn a_valid_name_is_parsed_successfully() {
        let name = "Ursula Le Guin".to_string();
        assert_ok!(SubscriberName::parse(name));
    }
}
