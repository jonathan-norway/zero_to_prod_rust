use std::net::TcpListener;

use actix_web::{App, HttpServer, dev::Server, middleware::Logger, web};
use sqlx::PgPool;

use crate::routes::{greet, health_check, subscribe};

pub fn run(listender: TcpListener, connection_pool: PgPool) -> Result<Server, std::io::Error> {
    let connection_pool = web::Data::new(connection_pool);
    let server = HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .route("/", web::get().to(greet))
            .route("/health_check", web::get().to(health_check))
            .route("/subscribe", web::post().to(subscribe))
            .route("/{name}", web::get().to(greet))
            .app_data(connection_pool.clone())
    })
    .listen(listender)?
    .run();
    Ok(server)
}
