import 'package:material_ui/material_ui.dart';

import '../models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});
  final Project project;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(project.title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.projectImageUrl.isNotEmpty) ...[
            Image.network(
              project.projectImageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stackTrace) => const SizedBox(
                height: 100,
                child: Center(child: Text('Gambar tidak dapat dimuat.')),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            project.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(project.description),
          const SizedBox(height: 20),
          Text('Tech Stack: ${project.techStack}'),
          const SizedBox(height: 12),
          SelectableText('Project URL: ${project.projectUrl}'),
        ],
      ),
    ),
  );
}
