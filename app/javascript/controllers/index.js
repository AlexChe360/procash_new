// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import BottomSheetController from "./bottom_sheet_controller"
import PreloaderController from "./preloader_controller"
import RetryRequestController from "./retry_request_controller";

application.register("bottom-sheet", BottomSheetController)
application.register("preloader", PreloaderController)
application.register("retry-request", RetryRequestController);





