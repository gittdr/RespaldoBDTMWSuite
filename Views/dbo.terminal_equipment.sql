SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[terminal_equipment]
AS
SELECT
  'TRL' unit_type,
  'Trailer' unit_description,
  trl_id unit_id,
  trl_number unit_number,
  trl_status unit_status,
  trl_terminal home_terminal,
  trl_len unit_len,
  trl_wdth unit_wdth,
  trl_ht unit_ht,
  trl_grosswgt unit_grossweight,
  trl_tareweight unit_tareweight,
  trl_palletcount unit_palletcount,
  ai.cmp_id cmp_id,
  ai.dock_zone dock_zone,
  tz.zone_description dock_zone_description,
  ai.move_status move_status,
  ai.move_task_id move_task_id,
  ai.work_status work_status,
  ai.work_task_id work_task_id,
  ai.status_ts status_ts,
  ai.door_number door_number,
  trl_avail_cmp_id avail_cmp_id,
  trl_avail_date avail_date,
  trl_avail_city avail_city,
  (select cty_nmstct from city c where c.cty_code = trl.trl_avail_city) avail_city_nmstct
FROM trailerprofile trl, asset_ltl_info ai 
LEFT OUTER JOIN terminalzone tz ON tz.cmp_id = ai.cmp_id and tz.dock_zone = ai.dock_zone
where
 trl.trl_id = ai.unit_id
 and ai.unit_type = 'TRL'
UNION
SELECT
  'STR' unit_type,
  'Straight Truck' unit_description,
  trc_number unit_id,
  trc_number unit_number,
  trc_status unit_status,
  trc_terminal home_terminal,
  0 unit_len,
  0 unit_wdth,
  0 unit_ht,
  trc_grosswgt unit_grossweight,
  trc_tareweight unit_tareweight,
  0 unit_palletcount,
  ai.cmp_id cmp_id,
  ai.dock_zone dock_zone,
  tz.zone_description dock_zone_description,
  ai.move_status move_status,
  ai.move_task_id move_task_id,
  ai.work_status work_status,
  ai.work_task_id work_task_id,
  ai.status_ts status_ts,
  ai.door_number door_number,
  trc_avl_cmp_id avail_cmp_id,
  trc_avl_date avail_date,
  trc_avl_city avail_city,
  (select cty_nmstct from city c where c.cty_code = trc.trc_avl_city) avail_city_nmstct
FROM tractorprofile trc, asset_ltl_info ai 
LEFT OUTER JOIN terminalzone tz ON tz.cmp_id = ai.cmp_id and tz.dock_zone = ai.dock_zone
where
 trc.trc_number = ai.unit_id
 and ai.unit_type = 'STR'
 and trc_require_drvtrl=5
UNION
SELECT
  'TRC' unit_type,
  'Tractor' unit_description,
  trc_number unit_id,
  trc_number unit_number,
  trc_status unit_status,
  trc_terminal home_terminal,
  0 unit_len,
  0 unit_wdth,
  0 unit_ht,
  trc_grosswgt unit_grossweight,
  trc_tareweight unit_tareweight,
  0 unit_palletcount,
  ai.cmp_id cmp_id,
  ai.dock_zone dock_zone,
  tz.zone_description dock_zone_description,
  ai.move_status move_status,
  ai.move_task_id move_task_id,
  ai.work_status work_status,
  ai.work_task_id work_task_id,
  ai.status_ts status_ts,
  ai.door_number door_number,
  trc_avl_cmp_id avail_cmp_id,
  trc_avl_date avail_date,
  trc_avl_city avail_city,
  (select cty_nmstct from city c where c.cty_code = trc.trc_avl_city) avail_city_nmstct
FROM tractorprofile trc, asset_ltl_info ai 
LEFT OUTER JOIN terminalzone tz ON tz.cmp_id = ai.cmp_id and tz.dock_zone = ai.dock_zone
where
 trc.trc_number = ai.unit_id
 and ai.unit_type = 'TRC'
 and trc_require_drvtrl<>5
GO
GRANT DELETE ON  [dbo].[terminal_equipment] TO [public]
GO
GRANT INSERT ON  [dbo].[terminal_equipment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminal_equipment] TO [public]
GO
GRANT SELECT ON  [dbo].[terminal_equipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminal_equipment] TO [public]
GO
