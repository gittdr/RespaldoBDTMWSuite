CREATE TABLE [dbo].[jws_audit]
(
[jwsa_id] [int] NOT NULL IDENTITY(1, 1),
[jwsa_master_order] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jwsa_deliverydate] [datetime] NULL,
[jwsa_ticketnumber] [int] NULL,
[ord_hdrnumber] [int] NULL,
[jwsa_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jwsa_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jwsa_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jws_tareweight] [int] NULL,
[jws_weight] [int] NULL,
[jwsa_action] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jwsa_audit_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jwsa_audit_dttm] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[jws_audit] ADD CONSTRAINT [pk_jws_audit_jwsa_id] PRIMARY KEY CLUSTERED ([jwsa_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_jws_audit_jwsa_audit_dttm_jwsa_audit_user] ON [dbo].[jws_audit] ([jwsa_audit_dttm], [jwsa_audit_user]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[jws_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[jws_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[jws_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[jws_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[jws_audit] TO [public]
GO
