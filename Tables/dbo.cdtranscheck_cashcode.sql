CREATE TABLE [dbo].[cdtranscheck_cashcode]
(
[ctcc_id] [int] NOT NULL IDENTITY(1, 1),
[ctc_id] [int] NOT NULL,
[ctcc_cashamount] [money] NOT NULL,
[ctcc_cashcode] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdtranscheck_cashcode] ADD CONSTRAINT [pk_cdtranscheck_cashcode] PRIMARY KEY CLUSTERED ([ctcc_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_ctcc_id_amount] ON [dbo].[cdtranscheck_cashcode] ([ctc_id], [ctcc_cashamount]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdtranscheck_cashcode] ADD CONSTRAINT [fk_cdtranscheckcodetocdtranscheck] FOREIGN KEY ([ctc_id]) REFERENCES [dbo].[cdtranscheck] ([ctc_id])
GO
GRANT DELETE ON  [dbo].[cdtranscheck_cashcode] TO [public]
GO
GRANT INSERT ON  [dbo].[cdtranscheck_cashcode] TO [public]
GO
GRANT SELECT ON  [dbo].[cdtranscheck_cashcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdtranscheck_cashcode] TO [public]
GO
