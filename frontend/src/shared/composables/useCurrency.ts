const currencyFormatter = new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
});

export function useCurrency() {
    function formatCurrency(amount: number): string {
        return currencyFormatter.format(amount);
    }

    return { formatCurrency };
}
