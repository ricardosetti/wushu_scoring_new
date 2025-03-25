import bcrypt from 'bcrypt';

const passwords = [
  'AdminPass123',
  'HeadJudgePass123',
  'JudgeA1Pass123',
  'JudgeA2Pass123',
  'JudgeB1Pass123',
  'JudgeB2Pass123',
];

async function hashPasswords() {
  for (const password of passwords) {
    const hash = await bcrypt.hash(password, 10);
    console.log(`Password: ${password}, Hash: ${hash}`);
  }
}

hashPasswords();