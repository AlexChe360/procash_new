import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["sheet", "overlay"]

	open() {
		this.overlayTarget.classList.remove("hidden")
		this.sheetTarget.classList.remove("translate-y-full")
	}

	close() {
		this.overlayTarget.classList.add("hidden")
		this.sheetTarget.classList.add("translate-y-full")
	}
}
