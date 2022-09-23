CREATE TABLE [dbo].[trailercommhistory]
(
[tch_id] [int] NOT NULL IDENTITY(1, 1),
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_dttm] [datetime] NULL,
[tch_rcvd] [datetime] NULL,
[acm_system] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_batteryalert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_fuelalert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_pmalert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_temp1alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_temp2alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_temp3alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_temp4alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_temp5alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_ambient] [float] NULL,
[tch_discharge] [float] NULL,
[tch_cmpt1_return] [float] NULL,
[tch_cmpt1_setpoint] [float] NULL,
[tch_cmpt1_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_cmpt2_return] [float] NULL,
[tch_cmpt2_setpoint] [float] NULL,
[tch_cmpt2_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_cmpt3_return] [float] NULL,
[tch_cmpt3_setpoint] [float] NULL,
[tch_cmpt3_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_cmpt4_return] [float] NULL,
[tch_cmpt4_setpoint] [float] NULL,
[tch_cmpt4_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_cmpt5_return] [float] NULL,
[tch_cmpt5_setpoint] [float] NULL,
[tch_cmpt5_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_auxtemp1] [float] NULL,
[tch_auxtemp2] [float] NULL,
[tch_auxtemp3] [float] NULL,
[tch_auxtemp4] [float] NULL,
[tch_auxtemp5] [float] NULL,
[tch_door1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_door1b] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_door2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_door3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_door4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_door5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_hook] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_hooktractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_airbrake] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_intelliset] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_alarmsummary] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_reefermode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_power] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_servicestate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_standbystatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_standbyhours] [int] NULL,
[tch_switchonhours] [int] NULL,
[tch_triggerevent] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_afax] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_voltage] [float] NULL,
[tch_controlprobe] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_enginehrs] [int] NULL,
[tch_fuel] [float] NULL,
[tch_pmhour] [int] NULL,
[ckc_number] [int] NULL,
[tch_rpttype] [int] NULL,
[tch_loadedstatus] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_landmarkcity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_landmarkstate] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_landmarkname] [varchar] (220) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_motionstatus] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_dwellstatus] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_assettype] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_consumingexternalpower] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_powersource] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_reefer_remote_temperature_sensor1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_reefer_remote_temperature_sensor2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_reefer_remote_temperature_sensor3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_supply_air_temperature_zone1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_supply_air_temperature_zone2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_supply_air_temperature_zone3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_remote_switch1_open] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_remote_switch2_open] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_zone1_load_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_zone2_load_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_zone3_load_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tch_motionsummary] AS (case  when [tch_motionstatus]=[tch_dwellstatus] then [tch_motionstatus] when isnull([tch_dwellstatus],'')>'' AND isnull([tch_motionstatus],'')>'' then ((upper(left([tch_dwellstatus],(1)))+lower(right([tch_dwellstatus],len([tch_dwellstatus])-(1))))+', ')+[tch_motionstatus] when isnull([tch_motionstatus],'')>'' then upper(left([tch_dwellstatus],(1)))+lower(right([tch_dwellstatus],len([tch_dwellstatus])-(1))) when isnull([tch_dwellstatus],'')>'' then [tch_motionstatus] else nullif(isnull([tch_dwellstatus]+', ','')+isnull([tch_motionstatus],''),' ') end)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_ckafax] CHECK (([dbo].[CheckLabel]([tch_afax],'ReeferAfax',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_ckalarmsummary] CHECK (([dbo].[CheckLabel]([tch_alarmsummary],'ReeferAlarmSummary',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_ckreefermode] CHECK (([dbo].[CheckLabel]([tch_reefermode],'ReeferMode',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_ckservicestate] CHECK (([dbo].[CheckLabel]([tch_servicestate],'ReeferSrvcState',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_ckstandbystatus] CHECK (([dbo].[CheckLabel]([tch_standbystatus],'ReeferStandByStatus',(1))<>(0)))
GO
ALTER TABLE [dbo].[trailercommhistory] ADD CONSTRAINT [tch_pk] PRIMARY KEY CLUSTERED ([tch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_tch_ckcnumSearch] ON [dbo].[trailercommhistory] ([ckc_number], [tch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_tch_trlStatusSearch] ON [dbo].[trailercommhistory] ([trl_id], [tch_dttm], [tch_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_coveralarmsumm] ON [dbo].[trailercommhistory] ([trl_id], [tch_id], [tch_alarmsummary]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailercommhistory] TO [public]
GO
GRANT INSERT ON  [dbo].[trailercommhistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailercommhistory] TO [public]
GO
GRANT SELECT ON  [dbo].[trailercommhistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailercommhistory] TO [public]
GO
