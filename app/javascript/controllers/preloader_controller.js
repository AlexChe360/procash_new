import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["preloader"];

	connect() {
		this.showPreloader();
		// Скрыть прелоадер через несколько секунд
		setTimeout(() => {
			this.hidePreloader();
		}, 3000); // Время в миллисекундах (здесь 3 секунды)
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
