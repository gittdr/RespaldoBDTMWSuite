CREATE TABLE [dbo].[edi_orderstate]
(
[esc_code] [tinyint] NOT NULL,
[esc_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esc_tmwordersuspense] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_esc_tmwordersuspense] DEFAULT ('N'),
[esc_orderplanningallowed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_esc_orderplanningallowed] DEFAULT ('Y'),
[esc_orderdispatchallowed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_esc_orderdispatchallowed] DEFAULT ('Y'),
[esc_useractionrequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_esc_useractionrequired] DEFAULT ('Y')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_orderstate] ADD CONSTRAINT [cc_edi_orderstate_esc_orderdispatchallowed] CHECK (([esc_orderdispatchallowed]='N' OR [esc_orderdispatchallowed]='Y'))
GO
ALTER TABLE [dbo].[edi_orderstate] ADD CONSTRAINT [cc_edi_orderstate_esc_orderplanningallowed] CHECK (([esc_orderplanningallowed]='N' OR [esc_orderplanningallowed]='Y'))
GO
ALTER TABLE [dbo].[edi_orderstate] ADD CONSTRAINT [cc_edi_orderstate_esc_tmwordersuspense] CHECK (([esc_tmwordersuspense]='N' OR [esc_tmwordersuspense]='Y'))
GO
ALTER TABLE [dbo].[edi_orderstate] ADD CONSTRAINT [cc_edi_orderstate_esc_useractionrequired] CHECK (([esc_useractionrequired]='N' OR [esc_useractionrequired]='Y'))
GO
ALTER TABLE [dbo].[edi_orderstate] ADD CONSTRAINT [pk_edi_orderstate_esc_code] PRIMARY KEY CLUSTERED ([esc_code]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_edi_orderstate_esc_description] ON [dbo].[edi_orderstate] ([esc_description]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_orderstate] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_orderstate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_orderstate] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_orderstate] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_orderstate] TO [public]
GO
