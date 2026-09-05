import { z } from 'zod';

export const transferAmountSchema = z.object({
    targetAccountId: z
        .number({ message: 'Informe a conta de destino.' })
        .int('O número da conta deve ser inteiro.')
        .min(0, 'O número da conta não pode ser negativo.'),
    amount: z.number({ message: 'Informe um valor.' }).positive('O valor deve ser maior que zero.'),
});

export type TransferAmountValues = z.infer<typeof transferAmountSchema>;

export type TransferAmountDraft = {
    targetAccountId: number | null;
    amount: number | null;
};
