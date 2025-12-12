// Basic Email Simulation
export const sendEmail = async ({ to, subject, text }) => {
  console.log("========================================");
  console.log(`📧 MOCK EMAIL SENT TO: ${to}`);
  console.log(`📝 SUBJECT: ${subject}`);
  console.log(`TEXT: ${text}`);
  console.log("========================================");
  
  // TODO: In production, integrate Nodemailer or SendGrid here
  // import nodemailer from 'nodemailer';
  // ... implementation ...
  return true;
};