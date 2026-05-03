# Good and Bad Tests

## Good Tests

Integration-style: test through real interfaces.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

```python
# GOOD: Tests observable behavior
def test_user_can_checkout_with_valid_cart():
    cart = create_cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

- Tests behavior callers care about
- Public API only
- Survives internal refactors
- Describes WHAT, not HOW

## Bad Tests

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

```python
# BAD: Tests implementation details
def test_checkout_calls_payment_service(mocker):
    mock_process = mocker.patch("app.payment_service.process")
    checkout(cart, payment)
    mock_process.assert_called_once_with(cart.total)
```

Red flags:
- Mocking internal collaborators
- Testing private methods
- Asserting call counts/order
- Test breaks on refactor without behavior change

```typescript
// BAD: Bypasses interface
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

```python
# BAD: Bypasses interface
def test_create_user_saves_to_database(db_session):
    create_user(name="Alice")
    row = db_session.execute("SELECT * FROM users WHERE name = 'Alice'").fetchone()
    assert row is not None

# GOOD: Verifies through interface
def test_create_user_makes_user_retrievable():
    user = create_user(name="Alice")
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```