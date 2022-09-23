CREATE TABLE [dbo].[CreditToOrderMap]
(
[ctom_id] [int] NOT NULL IDENTITY(1, 1),
[ctom_ovr_id] [int] NOT NULL,
[ctom_ord_hdrnumber] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CreditToOrderMap] TO [public]
GO
GRANT INSERT ON  [dbo].[CreditToOrderMap] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CreditToOrderMap] TO [public]
GO
GRANT SELECT ON  [dbo].[CreditToOrderMap] TO [public]
GO
GRANT UPDATE ON  [dbo].[CreditToOrderMap] TO [public]
GO
