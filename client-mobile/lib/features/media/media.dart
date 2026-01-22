/// Media feature barrel exports
library media;

// Domain layer - entities
export 'domain/entities/media_entity.dart';

// Domain layer - repositories
export 'domain/repositories/media_repository.dart';

// Domain layer - use cases
export 'domain/usecases/upload_media.dart';
export 'domain/usecases/download_media.dart';
export 'domain/usecases/delete_media.dart';
export 'domain/usecases/list_media.dart';
export 'domain/usecases/get_media_metadata.dart';
export 'domain/usecases/get_thumbnail_url.dart';
export 'domain/usecases/manage_media_cache.dart';

// Data layer - datasources
export 'data/datasources/media_remote_datasource.dart';
export 'data/datasources/media_local_datasource.dart';

// Data layer - repositories
export 'data/repositories/media_repository_impl.dart';

// Presentation layer - bloc
export 'presentation/bloc/media_bloc.dart';
export 'presentation/bloc/media_event.dart';
export 'presentation/bloc/media_state.dart';

// Presentation layer - widgets
export 'presentation/widgets/media_picker_sheet.dart';
export 'presentation/widgets/media_preview.dart';
export 'presentation/widgets/avatar_widget.dart';
export 'presentation/widgets/upload_progress.dart';

// Presentation layer - pages
export 'presentation/pages/media_viewer_page.dart';
export 'presentation/pages/media_gallery_page.dart';
