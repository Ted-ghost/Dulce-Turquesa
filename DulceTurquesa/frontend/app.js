const API_BASE = window.location.port === "8000"
  ? "/api"
  : "http://127.0.0.1:8000/api";

const blankUser = () => ({ name: "", email: "", password: "", role: "vendedor", is_active: true });
const blankProduct = () => ({ name: "", category: "", price: null, stock: 0, description: "", is_active: true });
const blankIngredient = () => ({ name: "", unit: "kg", minimum_stock: 0, current_stock: 0 });
const blankOrder = () => ({ customer_name: "", product_id: "", quantity: 1 });
const cartKey = (user) => `dt_cart_${user?.email || "guest"}`;

Vue.createApp({
  data() {
    return {
      token: localStorage.getItem("dt_token") || "",
      currentUser: JSON.parse(localStorage.getItem("dt_user") || "null"),
      view: "dashboard",
      error: "",
      message: "",
      loginForm: { email: "admin@dulceturquesa.com", password: "Admin12345" },
      credentials: [
        { role: "Admin", email: "admin@dulceturquesa.com", password: "Admin12345" },
        { role: "Encargado", email: "encargado@dulceturquesa.com", password: "Encargado123" },
        { role: "Vendedor", email: "vendedor@dulceturquesa.com", password: "Vendedor123" },
        { role: "Cliente", email: "cliente@dulceturquesa.com", password: "Cliente123" },
      ],
      userForm: blankUser(),
      productForm: blankProduct(),
      ingredientForm: blankIngredient(),
      orderForm: blankOrder(),
      users: [],
      products: [],
      ingredients: [],
      orders: [],
      cart: [],
      report: {
        products: 0,
        active_users: 0,
        orders: 0,
        sales_total: 0,
        low_stock_ingredients: 0,
      },
      allMenu: [
        { id: "dashboard", label: "Panel", roles: ["admin", "encargado", "vendedor", "cliente"] },
        { id: "users", label: "Usuarios", roles: ["admin"] },
        { id: "products", label: "Productos", roles: ["admin", "encargado"] },
        { id: "shop", label: "Catalogo", roles: ["cliente"] },
        { id: "cart", label: "Carrito", roles: ["cliente"] },
        { id: "orders", label: "Pedidos / Ventas", roles: ["admin", "encargado", "vendedor"] },
        { id: "clientOrders", label: "Mis pedidos", roles: ["cliente"] },
        { id: "inventory", label: "Inventario", roles: ["admin", "encargado"] },
        { id: "reports", label: "Reportes", roles: ["admin", "encargado"] },
      ],
    };
  },
  computed: {
    role() {
      return this.currentUser?.role || "vendedor";
    },
    roleClass() {
      return `role-${this.role}`;
    },
    menu() {
      return this.allMenu.filter((item) => item.roles.includes(this.role));
    },
    activeTitle() {
      return this.menu.find((item) => item.id === this.view)?.label || "Panel";
    },
    rolePanel() {
      const panels = {
        admin: {
          title: "Administracion general",
          text: "Control completo de usuarios, catalogo, ventas, inventario y reportes.",
          image: "https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=900&q=85",
        },
        encargado: {
          title: "Operacion de panaderia",
          text: "Gestiona productos, ingredientes, ventas y alertas de stock para mantener la vitrina lista.",
          image: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=85",
        },
        vendedor: {
          title: "Mostrador y ventas",
          text: "Registra pedidos rapido, consulta productos disponibles y atiende clientes sin distracciones.",
          image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=85",
        },
        cliente: {
          title: "Compra tus favoritos",
          text: "Explora postres, cafes y panes, arma tu carrito y consulta el estado de tus pedidos.",
          image: "https://images.unsplash.com/photo-1517433670267-08bbd4be890f?auto=format&fit=crop&w=900&q=85",
        },
      };
      return panels[this.role] || panels.vendedor;
    },
    activeProducts() {
      return this.products.filter((product) => product.is_active && Number(product.stock) > 0);
    },
    cartTotal() {
      return this.cart.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);
    },
    cartCount() {
      return this.cart.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
    },
  },
  mounted() {
    if (this.token) {
      this.loadCart();
      this.loadAll();
    }
  },
  methods: {
    headers() {
      return {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.token}`,
      };
    },
    async request(path, options = {}) {
      this.error = "";
      const response = await fetch(`${API_BASE}${path}`, {
        ...options,
        headers: { ...this.headers(), ...(options.headers || {}) },
      });
      const text = await response.text();
      const data = text ? JSON.parse(text) : null;
      if (!response.ok) {
        throw new Error(data?.detail || "No se pudo completar la operacion.");
      }
      return data;
    },
    showMessage(text) {
      this.message = text;
      setTimeout(() => {
        this.message = "";
      }, 2600);
    },
    validatePassword(password) {
      return password.length >= 8 && /[A-Z]/.test(password) && /\d/.test(password);
    },
    async login() {
      try {
        const data = await fetch(`${API_BASE}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(this.loginForm),
        }).then(async (response) => {
          const payload = await response.json();
          if (!response.ok) throw new Error(payload.detail || "Login invalido.");
          return payload;
        });
        this.token = data.access_token;
        this.currentUser = data.user;
        this.view = "dashboard";
        localStorage.setItem("dt_token", this.token);
        localStorage.setItem("dt_user", JSON.stringify(data.user));
        this.loadCart();
        await this.loadAll();
      } catch (error) {
        this.error = error.message;
      }
    },
    logout() {
      this.token = "";
      this.currentUser = null;
      this.cart = [];
      localStorage.removeItem("dt_token");
      localStorage.removeItem("dt_user");
    },
    useCredential(credential) {
      this.loginForm.email = credential.email;
      this.loginForm.password = credential.password;
      this.error = "";
    },
    loadCart() {
      this.cart = JSON.parse(localStorage.getItem(cartKey(this.currentUser)) || "[]");
    },
    saveCart() {
      localStorage.setItem(cartKey(this.currentUser), JSON.stringify(this.cart));
    },
    async loadAll() {
      try {
        const loaders = [
          this.request("/products").then((data) => { this.products = data; }),
          this.request("/orders").then((data) => { this.orders = data; }),
        ];
        if (["admin", "encargado"].includes(this.role)) {
          loaders.push(this.request("/inventory").then((data) => { this.ingredients = data; }));
          loaders.push(this.request("/reports/summary").then((data) => { this.report = data; }));
        }
        if (this.role === "admin") {
          loaders.push(this.request("/users").then((data) => { this.users = data; }));
        }
        await Promise.all(loaders);
        if (["vendedor", "cliente"].includes(this.role)) {
          this.report = {
            ...this.report,
            products: this.products.length,
            orders: this.orders.length,
            sales_total: this.orders.reduce((sum, order) => sum + Number(order.total || 0), 0),
            low_stock_ingredients: 0,
          };
        }
        if (!this.menu.some((item) => item.id === this.view)) {
          this.view = "dashboard";
        }
      } catch (error) {
        this.error = error.message;
      }
    },
    async createUser() {
      try {
        if (!this.validatePassword(this.userForm.password)) {
          throw new Error("La contrasena debe tener 8 caracteres, una mayuscula y un numero.");
        }
        await this.request("/users", {
          method: "POST",
          body: JSON.stringify(this.userForm),
        });
        this.userForm = blankUser();
        await this.loadAll();
        this.showMessage("Usuario guardado.");
      } catch (error) {
        this.error = error.message;
      }
    },
    async createProduct() {
      try {
        if (Number(this.productForm.price) <= 0) throw new Error("El precio debe ser mayor a cero.");
        if (Number(this.productForm.stock) < 0) throw new Error("El stock no puede ser negativo.");
        await this.request("/products", {
          method: "POST",
          body: JSON.stringify(this.productForm),
        });
        this.productForm = blankProduct();
        await this.loadAll();
        this.showMessage("Producto guardado.");
      } catch (error) {
        this.error = error.message;
      }
    },
    async createIngredient() {
      try {
        if (Number(this.ingredientForm.current_stock) < 0) throw new Error("El stock actual no puede ser negativo.");
        await this.request("/inventory", {
          method: "POST",
          body: JSON.stringify(this.ingredientForm),
        });
        this.ingredientForm = blankIngredient();
        await this.loadAll();
        this.showMessage("Ingrediente guardado.");
      } catch (error) {
        this.error = error.message;
      }
    },
    async createOrder() {
      try {
        await this.request("/orders", {
          method: "POST",
          body: JSON.stringify({
            customer_name: this.orderForm.customer_name,
            items: [
              {
                product_id: Number(this.orderForm.product_id),
                quantity: Number(this.orderForm.quantity),
              },
            ],
          }),
        });
        this.orderForm = blankOrder();
        await this.loadAll();
        this.showMessage("Venta registrada.");
      } catch (error) {
        this.error = error.message;
      }
    },
    addToCart(product) {
      const existing = this.cart.find((item) => item.id === product.id);
      if (existing) {
        if (existing.quantity >= product.stock) {
          this.error = "No hay mas stock disponible para ese producto.";
          return;
        }
        existing.quantity += 1;
      } else {
        this.cart.push({
          id: product.id,
          name: product.name,
          price: product.price,
          stock: product.stock,
          quantity: 1,
        });
      }
      this.saveCart();
      this.showMessage("Producto agregado al carrito.");
    },
    updateCartQuantity(item, quantity) {
      item.quantity = Math.max(1, Math.min(Number(quantity || 1), Number(item.stock || 1)));
      this.saveCart();
    },
    removeFromCart(item) {
      this.cart = this.cart.filter((cartItem) => cartItem.id !== item.id);
      this.saveCart();
    },
    async checkoutCart() {
      try {
        if (!this.cart.length) throw new Error("El carrito esta vacio.");
        await this.request("/orders", {
          method: "POST",
          body: JSON.stringify({
            customer_name: this.currentUser.name,
            items: this.cart.map((item) => ({
              product_id: item.id,
              quantity: Number(item.quantity),
            })),
          }),
        });
        this.cart = [];
        this.saveCart();
        await this.loadAll();
        this.view = "clientOrders";
        this.showMessage("Pedido enviado correctamente.");
      } catch (error) {
        this.error = error.message;
      }
    },
    money(value) {
      return Number(value || 0).toFixed(2);
    },
    date(value) {
      return new Date(value).toLocaleString("es-MX");
    },
  },
}).mount("#app");
