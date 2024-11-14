
// app/javascript/controllers/retry_request_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["button", "preloader"];

	connect() {
		console.log("RetryRequestController подключён");

		setTimeout(() => {
			this.hidePreloader();
		}, 3000); // Время в миллисекундах (здесь 3 секунды)
	}

	retry() {
		this.showPreloader()
		const url = window.location.href; // Текущий URL страницы
		this.buttonTarget.disabled = true; // Отключаем кнопку, чтобы избежать множественных запросов

		fetch(url, {
			method: "GET",
			headers: {
				"Content-Type": "application/json",
				"X-Requested-With": "XMLHttpRequest"
			}
		})
			.then(response => {
				if (response.ok) {
					this.hidePreloader()
					return response.text(); // Ожидаем HTML ответа
				} else {
					throw new Error('Ошибка при повторе запроса');
				}
			})
			.then(html => {
				document.documentElement.innerHTML = html; // Перезаписываем HTML страницы
			})
			.catch(error => {
				console.error("Ошибка:", error);
				this.buttonTarget.disabled = false; // Включаем кнопку обратно при ошибке
			});
	}

	showPreloader() {
		const preloader = document.getElementById("preloader");
		if (preloader) {
			preloader.classList.remove("hidden");
		}
	}

	hidePreloader() {
		const preloader = document.getElementById("preloader");
		if (preloader) {
			preloader.classList.add("hidden");
		}
	}
}
