CREATE TABLE [dbo].[minwagecalculations]
(
[mwc_ID] [int] NOT NULL IDENTITY(1, 1),
[pyd_number] [int] NOT NULL,
[pyh_number] [int] NOT NULL,
[mwc_hours] [decimal] (10, 4) NOT NULL,
[mwc_minrate] [decimal] (10, 4) NOT NULL,
[mwc_pay] [money] NOT NULL,
[mwc_minpay] [money] NOT NULL,
[mwc_adjf] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_mwcID] ON [dbo].[minwagecalculations] ([mwc_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[minwagecalculations] TO [public]
GO
GRANT INSERT ON  [dbo].[minwagecalculations] TO [public]
GO
GRANT SELECT ON  [dbo].[minwagecalculations] TO [public]
GO
GRANT UPDATE ON  [dbo].[minwagecalculations] TO [public]
GO
