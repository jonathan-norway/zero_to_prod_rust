mod health_check;
mod subscriptions;

use actix_web::{HttpRequest, Responder};
pub use health_check::*;
pub use subscriptions::*;

pub async fn greet(req: HttpRequest) -> impl Responder {
    let name = req.match_info().get("name").unwrap_or("world");
    format!("Hello {}!", name)
}
