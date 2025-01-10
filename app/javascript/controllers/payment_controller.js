import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["payment", "overlay"]

	open(event) {
		this.overlayTarget.classList.remove("hidden")
		this.paymentTarget.classList.remove("translate-y-full")
		event.preventDefault();

		// Извлечение данных из атрибутов кнопки
		const orderId = this.element.dataset.orderId;
		const amount = this.element.dataset.amount;
		const description = this.element.dataset.description;

		const data = {
			pg_order_id: orderId,
			pg_amount: amount,
			pg_description: description
		};

		// Отправляем POST-запрос на сервер
		fetch("/payments", {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"X-CSRF-Token": this.getCsrfToken() // Получаем CSRF-токен для защиты
			},
			body: JSON.stringify(data)
		}).then(response => {
			if (!response.ok) {
				throw new Error("Ошибка при выполнении запроса");
			}
			return response.json();
		}).then(data => {
			console.log("Ответ сервера:", data);
			// Вы можете перенаправить пользователя на страницу успеха
			// или выполнить другие действия
		}).catch(error => {
			console.error("Ошибка:", error);
			alert("Что-то пошло не так. Попробуйте еще раз.");
		});
	}

	getCsrfToken() {
		return document.querySelector('meta[name="csrf-token"]').getAttribute("content");
	}

	close() {
		this.overlayTarget.classList.add("hidden")
		this.paymentTarget.classList.add("translate-y-full")
	}
}
