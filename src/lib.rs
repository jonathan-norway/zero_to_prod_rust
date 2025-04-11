use std::net::TcpListener;

use actix_web::{App, HttpRequest, HttpResponse, HttpServer, Responder, dev::Server, web};
use serde::Deserialize;
pub mod configuration;
pub mod routes;
pub mod startup;
