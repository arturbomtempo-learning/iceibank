import { z } from 'zod';

export const transferSchema = z
    .object({
        sourceAccountId: z
            .number({ message: 'Informe a conta de origem.' })
            .int('O número da conta deve ser inteiro.')
            .min(0, 'O número da conta não pode ser negativo.'),
        targetAccountId: z
            .number({ message: 'Informe a conta de destino.' })
            .int('O número da conta deve ser inteiro.')
            .min(0, 'O número da conta não pode ser negativo.'),
        amount: z
            .number({ message: 'Informe um valor.' })
            .positive('O valor deve ser maior que zero.'),
    })
    .refine((values) => values.sourceAccountId !== values.targetAccountId, {
        message: 'A conta de destino deve ser diferente da origem.',
        path: ['targetAccountId'],
    });

export type TransferValues = z.infer<typeof transferSchema>;

export type TransferDraft = {
    sourceAccountId: number | null;
    targetAccountId: number | null;
    amount: number | null;
};
