# Qubah Learning App - Core Backend Code Stubs

This artifact provides the core code stubs for the standalone Laravel backend. These files follow the architecture defined in the previous artifact.

## 🗄️ Database Migrations

### Create Subjects Table

```php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};
```

### Create Contents Table

```php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('contents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('topic_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->enum('type', ['video', 'audio', 'pdf', 'interactive']);
            $table->string('file_path')->nullable();
            $table->string('url')->nullable();
            $table->json('metadata')->nullable();
            $table->integer('order')->default(0);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('contents');
    }
};
```

## 🏛️ Models

### Subject Model

```php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Subject extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'thumbnail_url',
        'is_active',
    ];

    public function topics()
    {
        return $this->hasMany(Topic::class)->orderBy('order');
    }
}
```

### Content Model

```php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Content extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'topic_id',
        'title',
        'type',
        'file_path',
        'url',
        'metadata',
        'order',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    public function topic()
    {
        return $this->belongsTo(Topic::class);
    }
}
```

## 📡 API Layer

### Subject Resource (DTO)

```php
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'thumbnail_url' => $this->thumbnail_url,
            'topics' => TopicResource::collection($this->whenLoaded('topics')),
            'created_at' => $this->created_at,
        ];
    }
}
```

### Subject Controller (Thin)

```php
namespace App\Http\Controllers\Api\v1;

use App\Http\Controllers\Controller;
use App\Http\Resources\SubjectResource;
use App\Services\SubjectService;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    protected $subjectService;

    public function __construct(SubjectService $subjectService)
    {
        $this->subjectService = $subjectService;
    }

    public function index()
    {
        $subjects = $this->subjectService->getAllActiveSubjects();
        return SubjectResource::collection($subjects);
    }

    public function show($id)
    {
        $subject = $this->subjectService->getSubjectWithTopics($id);
        return new SubjectResource($subject);
    }
}
```

## 🧠 Service Layer

### Subject Service

```php
namespace App\Services;

use App\Models\Subject;

class SubjectService
{
    public function getAllActiveSubjects()
    {
        return Subject::where('is_active', true)->get();
    }

    public function getSubjectWithTopics($id)
    {
        return Subject::with('topics')->findOrFail($id);
    }
}
```

---
> [!NOTE]
> These are stubs and need to be placed in a proper Laravel project structure.
