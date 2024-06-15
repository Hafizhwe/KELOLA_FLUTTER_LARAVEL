<?php

namespace App\Models\API;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Data extends Model
{
    protected $fillable = [
        'type',         // jenis data (misal: income, expense, bill)
        'date',         // tanggal transaksi
        'amount',       // jumlah transaksi
        'source_bank',  // bank sumber
        'notes',        // catatan
        'user_id',      // id pengguna yang membuat transaksi
    ];

    // Relasi dengan model User (satu transaksi dimiliki oleh satu user)
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Contoh metode untuk mengambil jumlah transaksi berdasarkan jenis
    public static function getTotalByType($type)
    {
        return self::where('type', $type)->sum('amount');
    }
}
