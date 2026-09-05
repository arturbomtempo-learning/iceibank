import { z } from 'zod';

const accountNumber = z
    .number({ message: 'Informe o número da conta.' })
    .int('O número da conta deve ser inteiro.')
    .min(0, 'O número da conta não pode ser negativo.');

const positiveAmount = z
    .number({ message: 'Informe um valor.' })
    .positive('O valor deve ser maior que zero.');

export const accountLookupSchema = z.object({
    accountId: accountNumber,
});

export const amountSchema = z.object({
    amount: positiveAmount,
});

export const createAccountSchema = z.object({
    accountId: accountNumber,
    holderName: z.string().trim().min(1, 'Informe o nome do titular.'),
    owner: z.string().trim().min(1, 'Informe o usuário dono da conta.'),
    initialBalance: z
        .number({ message: 'Informe o saldo inicial.' })
        .min(0, 'O saldo inicial não pode ser negativo.'),
});

export type AccountLookupValues = z.infer<typeof accountLookupSchema>;
export type AmountValues = z.infer<typeof amountSchema>;
export type CreateAccountValues = z.infer<typeof createAccountSchema>;

export type AccountLookupDraft = {
    accountId: number | null;
};

export type AmountDraft = {
    amount: number | null;
};

export type CreateAccountDraft = {
    accountId: number | null;
    holderName: string;
    owner: string;
    initialBalance: number | null;
};
