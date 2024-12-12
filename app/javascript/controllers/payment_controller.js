import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["payment", "overlay"]

	open() {
		console.log("Открытие окна оплаты") // Для отладки
		this.overlayTarget.classList.remove("hidden")
		this.paymentTarget.classList.remove("translate-y-full")
	}

	close() {
		console.log("Закрытие окна оплаты") // Для отладки
		this.overlayTarget.classList.add("hidden")
		this.paymentTarget.classList.add("translate-y-full")
	}
}
