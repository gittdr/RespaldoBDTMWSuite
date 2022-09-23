CREATE TABLE [dbo].[associate_inv_pay_release]
(
[type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [int] NOT NULL,
[allow_release] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NULL,
[createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_inv_pay_release] ADD CONSTRAINT [associate_inv_pay_release_pk] PRIMARY KEY CLUSTERED ([type], [id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_inv_pay_release] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_inv_pay_release] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_inv_pay_release] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_inv_pay_release] TO [public]
GO
