import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["form", "preloader"];

	connect() {
		console.log("Payment Modal Controller connected");
	}

	submitPayment(event) {
		event.preventDefault(); // Останавливаем стандартное поведение формы

		// Показать прелоадер
		this.preloaderTarget.classList.remove("hidden");

		// Отправка формы через fetch
		fetch(this.formTarget.action, {
			method: "POST",
			headers: {
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
			},
			body: new FormData(this.formTarget)
		})
			.then(response => response.json())
			.then(data => {
				if (data.pg_redirect_url) {
					// Перенаправляем на страницу оплаты
					window.location.href = data.pg_redirect_url;
				} else {
					alert("Ошибка: " + data.pg_error_description);
				}
			})
			.catch(error => {
				console.error("Error:", error);
				alert("Произошла ошибка при обработке платежа.");
			})
			.finally(() => {
				// Скрыть прелоадер
				this.preloaderTarget.classList.add("hidden");
			});
	}
}
