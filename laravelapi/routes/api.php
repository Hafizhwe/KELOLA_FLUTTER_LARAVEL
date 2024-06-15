<?php

use App\Http\Controllers\API\Auth\AuthAPIController;
use App\Http\Controllers\API\TransactionAPIController;
use App\Http\Controllers\API\DataAPIController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/test', function() {
    return response([
        'message' => 'API is Working'
    ], 200);
});

Route::post('register', [AuthAPIController::class, 'register']);
Route::post('login', [AuthAPIController::class, 'login']);

Route::post('logout', [AuthAPIController::class, 'logout'])->middleware('auth:sanctum');

// Route untuk menyimpan transaksi baru
Route::post('/transactions', [TransactionAPIController::class, 'store'])->middleware('auth:sanctum');

// Route untuk mendapatkan semua transaksi pengguna (dashboard)
Route::get('/transactions', [TransactionAPIController::class, 'index'])->middleware('auth:sanctum');

Route::get('/data', [TransactionAPIController::class, 'index'])->middleware('auth:sanctum');
// Route untuk menampilkan semua data (data_screen)
Route::get('/data', [TransactionAPIController::class, 'getDataByMonthYear']);

// Route untuk menyimpan data baru (data_screen)
Route::post('/data', [TransactionAPIController::class, 'storeData']);

