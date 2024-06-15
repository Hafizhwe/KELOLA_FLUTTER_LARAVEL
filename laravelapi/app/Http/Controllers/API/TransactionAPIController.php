<?php

namespace App\Http\Controllers\API;

use App\Models\Transaction;
use App\Http\Controllers\Controller;
use App\Http\Requests\TransactionRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TransactionAPIController extends Controller
{
    public function index(Request $request)
    {
        try {
            // Mendapatkan pengguna yang terotentikasi
            $user = $request->user();
    
            // Jika pengguna tidak terotentikasi, kembalikan pesan kesalahan
            if (!$user) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }
    
            // Ambil data transaksi yang terkait dengan pengguna yang terotentikasi
            $transactions = Transaction::where('user_id', $user->id)->get();
    
            return response()->json([
                'transactions' => $transactions,
            ], 200);
        } catch (\Exception $e) {
            // Tangani pengecualian dan kembalikan pesan kesalahan
            return response()->json(['error' => 'Internal Server Error'], 500);
        }
    }

    public function store(TransactionRequest $request)
    {
        // Mendapatkan token dari header permintaan
        $token = $request->bearerToken();

        // Verifikasi token
        if (!$token) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Mendapatkan pengguna berdasarkan token
        $user = User::where('id', auth()->id())->first();

        // Pastikan pengguna terotentikasi sebelum melanjutkan
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Buat transaksi dengan 'user_id' yang sesuai
        $transactionData = [
            'type' => $request->type,
            'date' => $request->date,
            'amount' => $request->amount,
            'source_bank' => $request->source_bank,
            'notes' => $request->notes,
            'user_id' => $user->id // Menggunakan ID pengguna yang terotentikasi
        ];

        $transaction = Transaction::create($transactionData);

        return response()->json([
            'transaction' => $transaction,
            'message' => 'Transaction created successfully'
        ], 201);
    }
}
