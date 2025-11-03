/// Data models for Auth Service

/// Username validation result
#[derive(Debug)]
pub enum UsernameValidation {
    Valid,
    TooShort,
    TooLong,
    InvalidCharacters,
}

/// Validate username
pub fn validate_username(username: &str) -> UsernameValidation {
    if username.len() < 3 {
        return UsernameValidation::TooShort;
    }
    if username.len() > 32 {
        return UsernameValidation::TooLong;
    }
    
    // Only alphanumeric and underscore allowed
    if !username.chars().all(|c| c.is_alphanumeric() || c == '_') {
        return UsernameValidation::InvalidCharacters;
    }
    
    UsernameValidation::Valid
}

/// Password validation result
#[derive(Debug)]
pub enum PasswordValidation {
    Valid,
    TooShort,
}

/// Validate password (minimum 12 characters)
pub fn validate_password(password: &str) -> PasswordValidation {
    if password.len() < 12 {
        return PasswordValidation::TooShort;
    }
    PasswordValidation::Valid
}

/// Device type validation
pub fn is_valid_device_type(device_type: &str) -> bool {
    matches!(device_type, "ios" | "android" | "web" | "desktop")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_username_validation() {
        assert!(matches!(validate_username("john_doe"), UsernameValidation::Valid));
        assert!(matches!(validate_username("user123"), UsernameValidation::Valid));
        assert!(matches!(validate_username("ab"), UsernameValidation::TooShort));
        assert!(matches!(
            validate_username("this_is_a_very_long_username_that_exceeds_limit"),
            UsernameValidation::TooLong
        ));
        assert!(matches!(
            validate_username("john-doe"),
            UsernameValidation::InvalidCharacters
        ));
        assert!(matches!(
            validate_username("john@doe"),
            UsernameValidation::InvalidCharacters
        ));
    }

    #[test]
    fn test_password_validation() {
        assert!(matches!(validate_password("verylongpassword123"), PasswordValidation::Valid));
        assert!(matches!(validate_password("short"), PasswordValidation::TooShort));
        assert!(matches!(validate_password("exactlytwelv"), PasswordValidation::Valid));
    }

    #[test]
    fn test_device_type_validation() {
        assert!(is_valid_device_type("ios"));
        assert!(is_valid_device_type("android"));
        assert!(is_valid_device_type("web"));
        assert!(is_valid_device_type("desktop"));
        assert!(!is_valid_device_type("unknown"));
        assert!(!is_valid_device_type("mobile"));
    }
}
