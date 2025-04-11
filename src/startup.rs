use std::net::TcpListener;

use actix_web::{App, HttpServer, dev::Server, web};

use crate::routes::{greet, health_check, subscribe};

pub fn run(listender: TcpListener) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(greet))
            .route("/health_check", web::get().to(health_check))
            .route("/subscribe", web::post().to(subscribe))
            .route("/{name}", web::get().to(greet))
    })
    .listen(listender)?
    .run();
    Ok(server)
}
