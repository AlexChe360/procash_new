// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import BottomSheetController from "./bottom_sheet_controller"
import PreloaderController from "./preloader_controller"

application.register("bottom-sheet", BottomSheetController)
application.register("preloader", PreloaderController)

eagerLoadControllersFrom("controllers", application)




