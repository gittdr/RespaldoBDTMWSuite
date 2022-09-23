CREATE TABLE [dbo].[commodity]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_c__7DAE7A68] DEFAULT ('UNKNOWN'),
[cmd_pin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_stcc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_hazardous] [int] NULL,
[cmd_code_num] [int] NOT NULL,
[timestamp] [timestamp] NULL,
[cmd_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_specificgravity] [float] NULL,
[cmd_gravtemperature] [float] NULL,
[cmd_temperatureunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_t__7EA29EA1] DEFAULT ('C'),
[cmd_taxtable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_t__7F96C2DA] DEFAULT ('Y'),
[cmd_taxtable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_t__008AE713] DEFAULT ('Y'),
[cmd_taxtable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_t__017F0B4C] DEFAULT ('N'),
[cmd_taxtable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_t__02732F85] DEFAULT ('N'),
[cmd_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__commodity__cmd_u__036753BE] DEFAULT (suser_sname()),
[cmd_updateddate] [datetime] NULL CONSTRAINT [DF__commodity__cmd_u__045B77F7] DEFAULT (getdate()),
[cmd_createdate] [datetime] NULL CONSTRAINT [DF__commodity__cmd_c__054F9C30] DEFAULT (getdate()),
[cmd_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_cust_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_dot_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_waste_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_haz_class] DEFAULT ('UNK'),
[cmd_haz_subclass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_haz_subclass] DEFAULT ('UNK'),
[cmd_pin_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_risk] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_marine] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_spec_prov] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_flash_point] [float] NULL,
[cmd_flash_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_msds_dt] [datetime] NULL,
[cmd_min_spill] [float] NULL,
[cmd_health_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_flammable_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_reactivity_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_ppe_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_driver_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_ph] [float] NULL,
[cmd_color] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_water_soluble] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_top_load] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_viscosity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_spec_prep] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_foaming] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_osha] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_trl_wash_notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_custom_wash] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_makeup_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_imdg_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_imdg_class] DEFAULT ('UNK'),
[cmd_imdg_subclass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_imdg_subclass] DEFAULT ('UNK'),
[cmd_adr_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_adr_class] DEFAULT ('UNK'),
[cmd_adr_packaging_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_adr_pkggp] DEFAULT ('UNK'),
[cmd_adr_trem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_imdg_packaging_group] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_imdg_pkggp] DEFAULT ('UNK'),
[cmd_imdg_trem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_subclass2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_haz_subclass2] DEFAULT ('UNK'),
[cmd_imdg_subclass2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_commodity_cmd_imdg_subclass2] DEFAULT ('UNK'),
[cmd_flash_point_max] [float] NULL,
[cmd_non_spec] [int] NULL CONSTRAINT [DF_commodity_cmd_non_spec] DEFAULT (0),
[cmd_company_prohibited] [int] NULL CONSTRAINT [DF_commodity_ cmd_company_prohibited] DEFAULT (0),
[cmd_trlwsh_priority1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_trlwsh_priority2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_trlwsh_priority2_begin] [datetime] NULL,
[cmd_trlwsh_priority2_end] [datetime] NULL,
[cmd_default_length] [float] NULL,
[cmd_default_width] [float] NULL,
[cmd_default_height] [float] NULL,
[cmd_default_weight] [float] NULL,
[cmd_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_lghtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_lghtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_telephone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_class2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_Class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_displaycolor] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_TaxClass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_aceok] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_commodity_cmd_aceok] DEFAULT ('N'),
[cmd_aciok] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_commodity_cmd_aciok] DEFAULT ('N'),
[cmd_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__commodity__cmd_e__54A508CD] DEFAULT ('N'),
[cmd_app_eqcodes] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_ams_compcode] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_ams_reason] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_ams_complaint] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_rvp] [float] NULL,
[cmd_size] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_commodity] ON [dbo].[commodity] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from freightdetail, deleted
     where deleted.cmd_code = freightdetail.cmd_code ) 
   begin
-- Sybase Syntax
--   raiserror 99999 'Cannot delete commodity: Assigned to trips'
-- MSS Syntax
     raiserror('Cannot delete commodity: Assigned to trips',16,1)
     rollback transaction
   end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Trigger dbo.dt_commodity    Script Date: 6/1/99 11:55:16 AM ******/
CREATE TRIGGER [dbo].[iut_commodity] ON [dbo].[commodity] 
FOR INSERT,UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE	@autocreate		VARCHAR(6),
		@hazmatcode1	VARCHAR(6),
		@hazmatcode2	VARCHAR(6),
		@hazmatcode3	VARCHAR(6),
		@hazmatcode4	VARCHAR(6),
		@nextsequence	INTEGER

SELECT 	@autocreate = gi_string1
  FROM	generalinfo
 WHERE	gi_name = 'AutoCreateHazMatLdRq'

IF @autocreate <> 'Y' RETURN

SELECT 	@hazmatcode1 = ISNULL(gi_string1, ''),
		@hazmatcode2 = ISNULL(gi_string2, ''),
		@hazmatcode3 = ISNULL(gi_string3, ''),
		@hazmatcode4 = ISNULL(gi_string4, '')
FROM	generalinfo
WHERE	gi_name = 'HazMatLdRqCode'

IF UPDATE(cmd_hazardous)
BEGIN
	IF EXISTS(SELECT * FROM inserted WHERE cmd_hazardous = 1)
	BEGIN
		IF NOT EXISTS(SELECT 	* 
						FROM 	loadreqdefault, inserted
					   WHERE	loadreqdefault.def_cmd_id  = inserted.cmd_code AND
								def_type = @hazmatcode1) AND
			LTRIM(RTRIM(@hazmatcode1)) <> ''
		BEGIN
			INSERT loadreqdefault
				(def_id_type, 
				 def_not, 
				 def_id,  
				 def_type,  
				 def_manditory , 
				 def_quantity, 
				 def_equip_type ,
				 def_cmd_id,
				 def_required,
				 def_expire_date)
				(SELECT	'BOTH',
						'Y',
						'UNKNOWN',
						@hazmatcode1,
						'Y',
						1,
						'DRV',
						cmd_code,
						'Y',
						'20491231 23:59'
				   FROM	inserted)
					
		END
		IF NOT EXISTS(SELECT 	* 
						FROM 	loadreqdefault, inserted
					   WHERE	loadreqdefault.def_cmd_id  = inserted.cmd_code AND
								def_type = @hazmatcode2) AND
			LTRIM(RTRIM(@hazmatcode2)) <> ''
		BEGIN
			INSERT loadreqdefault
				(def_id_type, 
				 def_not, 
				 def_id,  
				 def_type,  
				 def_manditory , 
				 def_quantity, 
				 def_equip_type ,
				 def_cmd_id,
				 def_required,
				 def_expire_date)
				(SELECT	'BOTH',
						'Y',
						'UNKNOWN',
						@hazmatcode2,
						'Y',
						1,
						'DRV',
						cmd_code,
						'Y',
						'20491231 23:59'
				   FROM	inserted)
					
		END
		IF NOT EXISTS(SELECT 	* 
						FROM 	loadreqdefault, inserted
					   WHERE	loadreqdefault.def_cmd_id  = inserted.cmd_code AND
								def_type = @hazmatcode3) AND
			LTRIM(RTRIM(@hazmatcode3)) <> ''
		BEGIN
			INSERT loadreqdefault
				(def_id_type, 
				 def_not, 
				 def_id,  
				 def_type,  
				 def_manditory , 
				 def_quantity, 
				 def_equip_type ,
				 def_cmd_id,
				 def_required,
				 def_expire_date)
				(SELECT	'BOTH',
						'Y',
						'UNKNOWN',
						@hazmatcode3,
						'Y',
						1,
						'DRV',
						cmd_code,
						'Y',
						'20491231 23:59'
				   FROM	inserted)
					
		END
		IF NOT EXISTS(SELECT 	* 
						FROM 	loadreqdefault, inserted
					   WHERE	loadreqdefault.def_cmd_id  = inserted.cmd_code AND
								def_type = @hazmatcode4) AND
			LTRIM(RTRIM(@hazmatcode4)) <> ''
		BEGIN
			INSERT loadreqdefault
				(def_id_type, 
				 def_not, 
				 def_id,  
				 def_type,  
				 def_manditory , 
				 def_quantity, 
				 def_equip_type ,
				 def_cmd_id,
				 def_required,
				 def_expire_date)
				(SELECT	'BOTH',
						'Y',
						'UNKNOWN',
						@hazmatcode4,
						'Y',
						1,
						'DRV',
						cmd_code,
						'Y',
						'20491231 23:59'
				   FROM	inserted)
					
		END
	END
END		
GO
CREATE UNIQUE CLUSTERED INDEX [cmd_code] ON [dbo].[commodity] ([cmd_code]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cmd_code_num] ON [dbo].[commodity] ([cmd_code_num]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cmd_name] ON [dbo].[commodity] ([cmd_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Commodity_timestamp] ON [dbo].[commodity] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity] TO [public]
GO
