<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\API\Data;
use App\Http\Requests\DataRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DataAPIController extends Controller
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
    
            // Ambil data 'Data' yang terkait dengan pengguna yang terotentikasi
            $data = Data::where('user_id', $user->id)->get();
    
            return response()->json([
                'data' => $data,
            ], 200);
        } catch (\Exception $e) {
            // Tangani pengecualian dan kembalikan pesan kesalahan
            return response()->json(['error' => 'Internal Server Error'], 500);
        }
    }

    public function store(DataRequest $request)
    {
        // Mendapatkan token dari header permintaan
        $token = $request->bearerToken();

        // Verifikasi token
        if (!$token) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Mendapatkan pengguna berdasarkan token
        $user = Auth::user();

        // Pastikan pengguna terotentikasi sebelum melanjutkan
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Buat data 'Data' dengan 'user_id' yang sesuai
        $data = Data::create([
            'type' => $request->type,
            'date' => $request->date,
            'amount' => $request->amount,
            'source_bank' => $request->source_bank,
            'notes' => $request->notes,
            'user_id' => $user->id // Menggunakan ID pengguna yang terotentikasi
        ]);

        return response()->json([
            'data' => $data,
            'message' => 'Data created successfully'
        ], 201);
    }

    // Implementasikan fungsi update dan delete jika diperlukan
    // public function update(DataRequest $request, $id) { ... }
    // public function destroy($id) { ... }
}
