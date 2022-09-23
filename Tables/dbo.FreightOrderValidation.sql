CREATE TABLE [dbo].[FreightOrderValidation]
(
[FreightOrderValidationId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[ErrorNumber] [int] NOT NULL,
[ErrorDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorMessage] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderValidation] ADD CONSTRAINT [PK_FreightOrderValidation] PRIMARY KEY CLUSTERED ([FreightOrderValidationId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_FreightOrderValidation_FreightOrderId] ON [dbo].[FreightOrderValidation] ([FreightOrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderValidation] ADD CONSTRAINT [FK_FreightOrderValidation_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId])
GO
GRANT DELETE ON  [dbo].[FreightOrderValidation] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderValidation] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderValidation] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderValidation] TO [public]
GO
