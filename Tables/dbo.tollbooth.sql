CREATE TABLE [dbo].[tollbooth]
(
[tb_ident] [int] NOT NULL IDENTITY(1, 1),
[tb_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_tollbooth_status] DEFAULT ('ACT'),
[tb_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tb_vendor_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tollbooth] ADD CONSTRAINT [pk_tollbooth_ident] PRIMARY KEY CLUSTERED ([tb_ident]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_tollbooth_name] ON [dbo].[tollbooth] ([tb_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tollbooth] TO [public]
GO
GRANT INSERT ON  [dbo].[tollbooth] TO [public]
GO
GRANT SELECT ON  [dbo].[tollbooth] TO [public]
GO
GRANT UPDATE ON  [dbo].[tollbooth] TO [public]
GO
