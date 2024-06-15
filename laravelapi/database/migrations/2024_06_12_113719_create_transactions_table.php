<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTransactionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
{
    if (!Schema::hasTable('transactions')) {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('type', ['income', 'expense', 'tagihan']);
            $table->date('date');
            $table->decimal('amount', 50, 2); // Menggunakan decimal untuk nilai uang
            $table->string('source_bank');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }
}

public function down()
{
    Schema::dropIfExists('transactions');
}
}
