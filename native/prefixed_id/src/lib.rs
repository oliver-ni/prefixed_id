use uuid::Uuid;

rustler::atoms! {
    ok,
    error
}

#[rustler::nif]
fn base62_encode(num: u128) -> String {
    base62::encode(num)
}

#[rustler::nif]
fn base62_decode(input: String) -> Result<u128, String> {
    base62::decode(input).map_err(|e| e.to_string())
}

#[rustler::nif]
fn cast_hex_encoded_uuid_to_raw(input: &str) -> Result<u128, String> {
    let uuid = Uuid::parse_str(input).map_err(|e| e.to_string())?;
    Ok(uuid.as_u128())
}

#[rustler::nif]
fn generate_numeric_uuidv7() -> u128 {
    Uuid::now_v7().as_u128()
}

rustler::init!(
    "Elixir.PrefixedID.Nifs",
    [base62_encode, base62_decode, generate_numeric_uuidv7]
);
