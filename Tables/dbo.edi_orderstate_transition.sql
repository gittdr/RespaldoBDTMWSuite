CREATE TABLE [dbo].[edi_orderstate_transition]
(
[evs_code] [tinyint] NOT NULL,
[evs_validnextcode] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_orderstate_transition] ADD CONSTRAINT [pk_edi_orderstate_transition_code_validnextcode] PRIMARY KEY CLUSTERED ([evs_code], [evs_validnextcode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_orderstate_transition] ADD CONSTRAINT [fk_edi_orderstate_transition_evs_code] FOREIGN KEY ([evs_code]) REFERENCES [dbo].[edi_orderstate] ([esc_code])
GO
ALTER TABLE [dbo].[edi_orderstate_transition] ADD CONSTRAINT [fk_edi_orderstate_transition_evs_validnextcode] FOREIGN KEY ([evs_validnextcode]) REFERENCES [dbo].[edi_orderstate] ([esc_code])
GO
GRANT DELETE ON  [dbo].[edi_orderstate_transition] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_orderstate_transition] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_orderstate_transition] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_orderstate_transition] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_orderstate_transition] TO [public]
GO
