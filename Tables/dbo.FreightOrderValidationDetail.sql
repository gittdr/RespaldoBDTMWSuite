CREATE TABLE [dbo].[FreightOrderValidationDetail]
(
[FreightOrderValidationDetailId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderValidationId] [bigint] NOT NULL,
[DetailType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DetailValue] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderValidationDetail] ADD CONSTRAINT [PK_FreightOrderValidationDetail] PRIMARY KEY CLUSTERED ([FreightOrderValidationDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_FreightOrderValidationDetail_FreightOrderValidationId] ON [dbo].[FreightOrderValidationDetail] ([FreightOrderValidationId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderValidationDetail] ADD CONSTRAINT [FK_FreightOrderValidationDetail_FreightOrderValidation] FOREIGN KEY ([FreightOrderValidationId]) REFERENCES [dbo].[FreightOrderValidation] ([FreightOrderValidationId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[FreightOrderValidationDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderValidationDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderValidationDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderValidationDetail] TO [public]
GO
