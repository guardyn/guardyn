//! Utility to list all users in TiKV database

use anyhow::Result;
use tikv_client::RawClient;

#[tokio::main]
async fn main() -> Result<()> {
    let pd_endpoints = std::env::var("GUARDYN_DATABASE__TIKV_PD_ENDPOINTS")
        .unwrap_or_else(|_| "127.0.0.1:2379".to_string());

    println!("Connecting to TiKV at {}...\n", pd_endpoints);

    let client = RawClient::new(vec![pd_endpoints]).await?;

    // Scan username index: /users/username/{username} -> user_id
    let start = b"/users/username/".to_vec();
    let mut end = start.clone();
    end.push(0xff);

    println!("=== Users in TiKV ===\n");

    let pairs = client.scan(start..end, 100).await?;

    if pairs.is_empty() {
        println!("No users found in database");
        return Ok(());
    }

    println!("Total users: {}\n", pairs.len());
    println!("{:-<60}", "");

    for kv in pairs {
        let key = String::from_utf8_lossy(kv.key().into());
        let user_id = String::from_utf8_lossy(kv.value());

        if let Some(username) = key.strip_prefix("/users/username/") {
            println!("Username: {}", username);
            println!("User ID:  {}", user_id);

            // Fetch full profile
            let profile_key = format!("/users/{}/profile", user_id).into_bytes();
            if let Ok(Some(data)) = client.get(profile_key).await {
                if let Ok(profile) = serde_json::from_slice::<serde_json::Value>(&data) {
                    if let Some(email) = profile.get("email").and_then(|e| e.as_str()) {
                        println!("Email:    {}", email);
                    }
                    if let Some(created) = profile.get("created_at").and_then(|c| c.as_i64()) {
                        let dt = chrono::DateTime::from_timestamp(created, 0)
                            .map(|d| d.format("%Y-%m-%d %H:%M:%S").to_string())
                            .unwrap_or_else(|| created.to_string());
                        println!("Created:  {}", dt);
                    }
                    if let Some(last_seen) = profile.get("last_seen").and_then(|l| l.as_i64()) {
                        let dt = chrono::DateTime::from_timestamp(last_seen, 0)
                            .map(|d| d.format("%Y-%m-%d %H:%M:%S").to_string())
                            .unwrap_or_else(|| last_seen.to_string());
                        println!("Last seen: {}", dt);
                    }
                }
            }
            println!("{:-<60}", "");
        }
    }

    Ok(())
}
