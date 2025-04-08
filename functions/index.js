const functions = require("firebase-functions");
const nodemailer = require("nodemailer"); 

// إعداد النقل للبريد الإلكتروني باستخدام المتغيرات البيئية
const transporter = nodemailer.createTransport({
service: "gmail",
auth: {
    user: functions.config().gmail.user,  // البريد الإلكتروني من المتغيرات البيئية
    pass: functions.config().gmail.pass,   // كلمة مرور البريد الإلكتروني من المتغيرات البيئية
},
});

// دالة Firebase لإرسال OTP عبر البريد الإلكتروني
exports.sendOTPEmail = functions.https.onRequest((req, res) => {
  const email = req.query.email;  // الحصول على البريد الإلكتروني من الطلب
  const otp = Math.floor(100000 + Math.random() * 900000);  // توليد OTP مكون من 6 أرقام
ؤي
  // إعداد رسالة البريد الإلكتروني
const mailOptions = {
    from: functions.config().gmail.user,  // البريد الإلكتروني من المتغيرات البيئية
    to: email,  // البريد الإلكتروني للمستقبل
    subject: "Your OTP Code",  // موضوع الرسالة
    text: `Your OTP code is: ${otp}`,  // نص الرسالة الذي يحتوي على OTP
};

  // إرسال البريد الإلكتروني
transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
return res.status(500).send(error.toString());
    }
    res.status(200).send("OTP sent successfully!");
});
});
