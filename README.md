# Delivery Diploma — Хүргэлтийн курьер апп

Курьерүүдэд зориулсан хүргэлтийн мобайл аппликейшн (React Native / Expo). Курьер боломжит хүргэлтүүдийг харж, ажил авч, бараа авах болон хүргэх цэгийг газрын зураг дээр хянаж, OTP кодоор хүргэлтийг баталгаажуулж, орлогоо хянадаг. Backend талаар тусдаа Merchant Portal (Next.js)-той нэг Supabase санг хуваалцана.

Хэрэглэгчийн интерфейс бүхэлдээ **монгол хэл** дээр (жишээ нь: "Нүүр", "Хүргэлт", "Орлого").

---

## Ашигласан технологи, хэрэгсэл

| Чиглэл | Технологи |
|--------|-----------|
| Framework | React Native `0.81.5`, Expo SDK `~54`, React `19.1.0` |
| Хэл | TypeScript `~5.9` |
| Навигаци | React Navigation (native-stack, bottom-tabs) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions, Realtime) |
| Газрын зураг | react-native-maps, expo-location |
| Загвар (UI) | StyleSheet + design constants, NativeWind (Tailwind for RN) |
| Форм / валидаци | react-hook-form, zod |
| Бусад | expo-image-picker, expo-document-picker, expo-haptics, lucide-react-native, AsyncStorage |
| Email (OTP) | Supabase Edge Function + nodemailer + Gmail SMTP |

---

## Суулгах болон ажиллуулах заавар (Installation & Setup)

### Шаардлага

- Node.js (LTS) болон npm
- Expo CLI (`npx expo` ашиглана, тусад нь суулгах шаардлагагүй)
- Supabase төслийн URL ба anon key

### 1. Эх кодыг татах

```bash
git clone <repository-url>
cd delivery_diploma
```

### 2. Хамаарлуудыг суулгах

```bash
npm install
```

### 3. Орчны хувьсагч тохируулах

Төслийн үндсэн хавтсанд `.env` файл үүсгэж дараах утгуудыг оруулна:

```bash
EXPO_PUBLIC_SUPABASE_URL=<таны-supabase-url>
EXPO_PUBLIC_SUPABASE_ANON_KEY=<таны-supabase-anon-key>
```

### 4. Аппыг ажиллуулах

```bash
npm run web        # Вэб хөтөч дээр (хөгжүүлэлтэд хамгийн түгээмэл)
npm start          # Expo dev server
npm run android    # Android emulator/төхөөрөмж
npm run ios        # iOS simulator
npm run lint       # ESLint шалгалт
```

### Supabase Edge Function (OTP email) тохируулах

```bash
supabase secrets set GMAIL_USER=<gmail-хаяг>
supabase secrets set GMAIL_APP_PASSWORD=<gmail-app-password>
supabase functions deploy send-otp-email
```

---

## Үндсэн функцууд

- **Бүртгэл / Нэвтрэлт** — курьерийн бүртгэл, нэвтрэлт (Supabase Auth).
- **KYC баталгаажуулалт** — иргэний үнэмлэх зэрэг бичиг баримтыг Supabase Storage-д байршуулж, админ зөвшөөрлийг хүлээх урсгал.
- **Боломжит хүргэлтүүд (Нүүр)** — нийтлэгдсэн ажлуудын нийтийн сан, realtime шинэчлэлттэй.
- **Ажил авах (Claim)** — атомик `claim_delivery_task` RPC, нэг идэвхтэй ажлын хязгаарлалттай.
- **Хүргэлтийн урсгал** — `draft → published → assigned → picked_up → delivered → completed` гэсэн төлвийн дамжлага.
- **Бараа авах / хүргэх хяналт** — газрын зураг дээр маршрут, байршил хянах.
- **OTP-ээр баталгаажуулах (EPOD)** — хүргэлт дуусахад 6 оронтой OTP-г email-ээр илгээж, bcrypt-ээр шалгана.
- **Орлого** — гүйцэтгэсэн хүргэлтүүдийн орлогын хяналт (`courier_earnings`).
- **Профайл** — курьерийн мэдээлэл, тохиргоо.

### Аппын төлвийн урсгал (навигаци)

- Нэвтрээгүй → Login / Register
- Нэвтэрсэн + KYC шаардлагатай → KYC дэлгэц
- Нэвтэрсэн + KYC илгээсэн → Зөвшөөрөл хүлээх дэлгэц
- Нэвтэрсэн + блоклогдсон → Блоклогдсон дэлгэц
- Нэвтэрсэн + зөвшөөрөгдсөн → Үндсэн апп (Tab-ууд)

---

## Төслийн бүтэц (товч)

```
src/
├── components/ui/     # Дахин ашиглагддаг UI компонентууд
├── config/            # Supabase client тохиргоо
├── constants/         # design.ts — өнгө, зай, радиус, фонт
├── context/           # CourierAuthContext, CartContext
├── navigation/        # Root navigator, tab бүтэц
├── screens/           # Дэлгэцүүд (courier/, auth/)
├── services/          # courierAuthService, deliveryTaskService, storageService
└── types/             # TypeScript төрлүүд

supabase/
├── migrations/        # SQL migration, RPC функцууд
└── functions/         # Edge Functions (send-otp-email)
```

---

## Гишүүд

| Нэр | Оюутны дугаар |
|-----|----------------|
| Ү. Тамир | s21c011b |
</content>
</invoke>
