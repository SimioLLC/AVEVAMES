/****** Object:  View [dbo].[Simio_Work_Orders_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Work_Orders_WWMES_View]
AS
SELECT        wo_id, wo_desc, item_id, bom_ver_id, spec_ver_id, req_qty, release_time_utc, release_time_local, req_finish_time_utc, req_finish_time_local, state_cd, wo_priority, 
                         cust_info, mo_id, production_schedule_id, notes, spare1, spare2, spare3, process_id
FROM            dbo.wo
WHERE        (state_cd < 2)

GO
/****** Object:  View [dbo].[Simio_Jobs_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Jobs_WWMES_View]
AS
SELECT        dbo.job.wo_id + '_' + dbo.job.oper_id + '_' + CONVERT(varchar, dbo.job.seq_no) AS wo_id_oper_id_seq_no, dbo.ent.ent_name, dbo.job.wo_id, dbo.job.oper_id, dbo.job.seq_no, 
                         ent_1.ent_name AS sched_ent_name, ent_2.ent_name AS run_ent_name, dbo.job.job_desc, dbo.job.state_cd, dbo.job.qty_reqd, dbo.job.qty_prod, dbo.job.est_prod_rate, dbo.job.display_seq, dbo.job.row_id, 
                         dbo.ent.ent_id, ent_1.ent_id AS Expr1, ent_2.ent_id AS Expr2, dbo.job.job_cost, ISNULL(dbo.job.est_setup_time, 0) AS est_setup_time, ISNULL(dbo.job.est_teardown_time, 0) AS est_teardown_time, 
                         dbo.job.first_job, ISNULL(dbo.job.sched_start_time_utc, '12/31/1999') AS sched_start_time_utc_mes, ISNULL(dbo.job.sched_start_time_local, '12/31/1999') AS sched_start_time_local_mes, 
                         ISNULL(dbo.job.sched_finish_time_utc, '12/31/1999') AS sched_finish_time_utc_mes, ISNULL(dbo.job.sched_finish_time_local, '12/31/1999') AS sched_finish_time_local_mes, ISNULL(dbo.job.act_start_time_utc, 
                         '12/31/1999') AS act_start_time_utc, ISNULL(dbo.job.act_start_time_local, '12/31/1999') AS act_start_time_local, ISNULL(dbo.job.act_finish_time_utc, '12/31/1999') AS act_finish_time_utc, 
                         ISNULL(dbo.job.act_finish_time_local, '12/31/1999') AS act_finish_time_local
FROM            dbo.job INNER JOIN
                         dbo.ent ON dbo.job.init_sched_ent_id = dbo.ent.ent_id LEFT OUTER JOIN
                         dbo.ent AS ent_2 ON dbo.job.run_ent_id = ent_2.ent_id LEFT OUTER JOIN
                         dbo.ent AS ent_1 ON dbo.job.target_sched_ent_id = ent_1.ent_id
WHERE        (dbo.job.state_cd < 4) AND EXISTS
                             (SELECT        wo_id, wo_desc, item_id, bom_ver_id, spec_ver_id, req_qty, release_time_utc, release_time_local, req_finish_time_utc, req_finish_time_local, state_cd, wo_priority, cust_info, mo_id, 
                                                         production_schedule_id, notes, spare1, spare2, spare3
                               FROM            dbo.Simio_Work_Orders_WWMES_View
                               WHERE        (wo_id = dbo.job.wo_id))

GO
/****** Object:  View [dbo].[Simio_Job_Boms_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Job_Boms_WWMES_View]
AS
SELECT        wo_id + '_' + oper_id + '_' + CONVERT(varchar, seq_no) AS wo_id_oper_id_seq_no, wo_id, oper_id, seq_no, bom_pos, item_id, def_lot_no, qty_per_parent_item, 
                         CASE WHEN dbo.job_bom.bom_pos > 0 THEN 'Consume' ELSE 'Produce' END AS material_use, ISNULL(spare1, 'False') AS release_holding_tank, mod_id
FROM            dbo.job_bom
WHERE        EXISTS
                             (SELECT        wo_id_oper_id_seq_no, ent_name, wo_id, oper_id, seq_no, sched_ent_name, run_ent_name, job_desc, state_cd, qty_reqd, qty_prod, est_prod_rate, display_seq, row_id, ent_id, Expr1, Expr2, 
                                                         job_cost, est_setup_time, est_teardown_time, first_job, sched_start_time_utc_mes, sched_start_time_local_mes, sched_finish_time_utc_mes, sched_finish_time_local_mes, act_start_time_utc, 
                                                         act_start_time_local, act_finish_time_utc, act_finish_time_local
                               FROM            dbo.Simio_Jobs_WWMES_View
                               WHERE        (wo_id = dbo.job_bom.wo_id) AND (oper_id = dbo.job_bom.oper_id) AND (seq_no = dbo.job_bom.seq_no))

GO
/****** Object:  View [dbo].[Simio_Item_Inv_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Simio_Item_Inv_ISA95_View]
AS
SELECT        dbo.item.item_id as MaterialName, dbo.item.item_desc as MaterialDesc, dbo.item.item_class_id as MaterialClass, dbo.item_inv.qty_left as Quantity, '' AS LotId, ISNULL(dbo.item_inv.expiry_date, getdate() + 356) AS expiry_date, dbo.item.row_id, 
                         dbo.item.spare1
FROM            dbo.item INNER JOIN
                         dbo.item_inv ON dbo.item.item_id = dbo.item_inv.item_id
WHERE        (dbo.item_inv.wo_id IS NULL)
UNION ALL
SELECT        dbo.item.item_id, dbo.item.item_desc, dbo.item.item_class_id, 0 AS qty_left, '' AS lot_no, getdate() + 356 AS expiry_date, dbo.item.row_id, dbo.item.spare1
FROM            dbo.item
GO
/****** Object:  View [dbo].[Simio_Items_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Simio_Items_ISA95_View]
AS
SELECT        MaterialName, MaterialDesc, MaterialClass as DisplayCategory, MaterialClass, ISNULL(spare1, 'Other') AS MaterialColor, 
                         ISNULL(spare1, 'Gray') AS gantt_color
FROM            dbo.Simio_Item_Inv_ISA95_View
GROUP BY MaterialName, MaterialDesc, MaterialClass, row_id, spare1
GO
/****** Object:  View [dbo].[Simio_Item_Inv_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Item_Inv_WWMES_View]
AS
SELECT        dbo.item.item_id, dbo.item.item_desc, dbo.item.item_class_id, dbo.item_inv.qty_left, dbo.item_inv.lot_no, ISNULL(dbo.item_inv.expiry_date, getdate() + 356) AS expiry_date, dbo.item.row_id, dbo.item.spare1
FROM            dbo.item INNER JOIN
                         dbo.item_inv ON dbo.item.item_id = dbo.item_inv.item_id
WHERE        (dbo.item_inv.wo_id IS NULL)
UNION ALL
SELECT        dbo.item.item_id, dbo.item.item_desc, dbo.item.item_class_id, 0 AS qty_left, '' AS lot_no, getdate() + 356 AS expiry_date, dbo.item.row_id, dbo.item.spare1
FROM            dbo.item

GO
/****** Object:  View [dbo].[Simio_Items_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Items_WWMES_View]
AS
SELECT        item_id, item_desc, item_class_id, item_id + '.QuantityAvailable' AS material_available_expression, SUM(qty_left) AS qty_left, row_id, 
                         ISNULL(spare1, 'Other') AS item_color, ISNULL(spare1, 'Gray') AS gantt_color
FROM            dbo.Simio_Item_Inv_WWMES_View
GROUP BY item_id, item_desc, item_class_id, row_id, spare1

GO
/****** Object:  View [dbo].[Simio_Work_Orders_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Work_Orders_ISA95_View]
AS
SELECT        wo_id, wo_desc, item_id, bom_ver_id, spec_ver_id, req_qty, release_time_utc, release_time_local, req_finish_time_utc, req_finish_time_local, state_cd, wo_priority, 
                         cust_info, mo_id, production_schedule_id, notes, spare1, spare2, spare3, process_id
FROM            dbo.wo
WHERE        (state_cd < 2)
GO
/****** Object:  View [dbo].[Simio_Jobs_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Jobs_ISA95_View]
AS
SELECT        dbo.job.wo_id + '_' + dbo.job.oper_id + '_' + CONVERT(varchar, dbo.job.seq_no) AS wo_id_oper_id_seq_no, dbo.ent.ent_name, dbo.job.wo_id, dbo.job.oper_id, dbo.job.seq_no, 
                         ent_1.ent_name AS sched_ent_name, ent_2.ent_name AS run_ent_name, dbo.job.job_desc, dbo.job.state_cd, dbo.job.qty_reqd, dbo.job.qty_prod, dbo.job.est_prod_rate, dbo.job.display_seq, dbo.job.row_id, 
                         dbo.ent.ent_id, ent_1.ent_id AS Expr1, ent_2.ent_id AS Expr2, dbo.job.job_cost, ISNULL(dbo.job.est_setup_time, 0) AS est_setup_time, ISNULL(dbo.job.est_teardown_time, 0) AS est_teardown_time, 
                         dbo.job.first_job, ISNULL(dbo.job.sched_start_time_utc, '12/31/1999') AS sched_start_time_utc_mes, ISNULL(dbo.job.sched_start_time_local, '12/31/1999') AS sched_start_time_local_mes, 
                         ISNULL(dbo.job.sched_finish_time_utc, '12/31/1999') AS sched_finish_time_utc_mes, ISNULL(dbo.job.sched_finish_time_local, '12/31/1999') AS sched_finish_time_local_mes, ISNULL(dbo.job.act_start_time_utc, 
                         '12/31/1999') AS act_start_time_utc, ISNULL(dbo.job.act_start_time_local, '12/31/1999') AS act_start_time_local, ISNULL(dbo.job.act_finish_time_utc, '12/31/1999') AS act_finish_time_utc, 
                         ISNULL(dbo.job.act_finish_time_local, '12/31/1999') AS act_finish_time_local
FROM            dbo.job INNER JOIN
                         dbo.ent ON dbo.job.init_sched_ent_id = dbo.ent.ent_id LEFT OUTER JOIN
                         dbo.ent AS ent_2 ON dbo.job.run_ent_id = ent_2.ent_id LEFT OUTER JOIN
                         dbo.ent AS ent_1 ON dbo.job.target_sched_ent_id = ent_1.ent_id
WHERE        (dbo.job.state_cd <= 4) AND EXISTS
                             (SELECT        wo_id, wo_desc, item_id, bom_ver_id, spec_ver_id, req_qty, release_time_utc, release_time_local, req_finish_time_utc, req_finish_time_local, state_cd, wo_priority, cust_info, mo_id, 
                                                         production_schedule_id, notes, spare1, spare2, spare3
                               FROM            dbo.Simio_Work_Orders_ISA95_View
                               WHERE        (wo_id = dbo.job.wo_id))
GO
/****** Object:  View [dbo].[Simio_Job_Boms_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Simio_Job_Boms_ISA95_View]
AS
SELECT        wo_id + '_' + oper_id + '_' + CONVERT(varchar, seq_no) AS wo_id_oper_id_seq_no, wo_id, oper_id, seq_no, bom_pos, item_id, def_lot_no, qty_per_parent_item, 
                         CASE WHEN dbo.job_bom.bom_pos > 0 THEN 'Consume' ELSE 'Produce' END AS material_use, ISNULL(spare1, 'False') AS release_holding_tank, mod_id
FROM            dbo.job_bom
WHERE        EXISTS
                             (SELECT        wo_id_oper_id_seq_no, ent_name, wo_id, oper_id, seq_no, sched_ent_name, run_ent_name, job_desc, state_cd, qty_reqd, qty_prod, est_prod_rate, display_seq, row_id, ent_id, Expr1, Expr2, 
                                                         job_cost, est_setup_time, est_teardown_time, first_job, sched_start_time_utc_mes, sched_start_time_local_mes, sched_finish_time_utc_mes, sched_finish_time_local_mes, act_start_time_utc, 
                                                         act_start_time_local, act_finish_time_utc, act_finish_time_local
                               FROM            dbo.Simio_Jobs_ISA95_View
                               WHERE        (wo_id = dbo.job_bom.wo_id) AND (oper_id = dbo.job_bom.oper_id) AND (seq_no = dbo.job_bom.seq_no))

GO
/****** Object:  View [dbo].[Simio_Ents_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Simio_Ents_ISA95_View]
AS
SELECT     dbo.ent.ent_id as EntId, dbo.ent.ent_name AS ResourceName, dbo.ent.description AS Description, ent_1.ent_name AS DisplayCategory, CASE WHEN dbo.ent.can_run_jobs = 1 THEN 'SchedServer' ELSE 'SchedTransferNode' END AS ObjectType, 
           dbo.ent.spare1 AS XLocation, dbo.ent.spare2 AS ZLocation
FROM        dbo.ent LEFT OUTER JOIN dbo.ent AS ent_1 ON dbo.ent.parent_ent_id = ent_1.ent_id
WHERE     (dbo.ent.can_sched_jobs = 1) OR
                  (dbo.ent.can_run_jobs = 1)
GO
/****** Object:  View [dbo].[Simio_Ents_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Ents_WWMES_View]
AS
SELECT     dbo.ent.ent_name, dbo.ent.description, dbo.ent.ent_id, CASE WHEN dbo.ent.can_run_jobs = 1 THEN 'MESServer' ELSE 'MESTransferNode' END AS object_type, dbo.ent.spare1 AS x_location, dbo.ent.spare2 AS z_location, ent_1.ent_name AS parent_ent_name
FROM        dbo.ent LEFT OUTER JOIN
                  dbo.ent AS ent_1 ON dbo.ent.parent_ent_id = ent_1.ent_id
WHERE     (dbo.ent.can_sched_jobs = 1) OR
                  (dbo.ent.can_run_jobs = 1)
GO
/****** Object:  View [dbo].[Simio_Item_Boms_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Simio_Item_Boms_ISA95_View]
AS
SELECT        dbo.bom_item_oper_link.process_id + '_' + dbo.bom_item_oper_link.oper_id + '_' + dbo.bom_item.parent_item_id as RoutingKey, dbo.bom_item.ver_id, 
                         dbo.bom_item.bom_pos, dbo.bom_item.item_id AS ComponentMaterial, dbo.bom_item_oper_link.oper_id, dbo.bom_item_oper_link.qty_per_parent_item as RequiredQuantity, dbo.bom_item_oper_link.process_id, 
                         CASE WHEN dbo.bom_item.bom_pos > 0 THEN 'Consume' ELSE 'Produce' END AS MaterialUse, ISNULL(dbo.bom_item.spare1, 'False') AS release_holding_tank, dbo.bom_item_oper_link.mod_id
FROM            dbo.bom_item INNER JOIN
                         dbo.bom_item_oper_link ON dbo.bom_item.parent_item_id = dbo.bom_item_oper_link.parent_item_id AND dbo.bom_item.ver_id = dbo.bom_item_oper_link.ver_id AND 
                         dbo.bom_item.bom_pos = dbo.bom_item_oper_link.bom_pos

GO
/****** Object:  View [dbo].[Simio_Item_Boms_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Item_Boms_WWMES_View]
AS
SELECT        dbo.bom_item_oper_link.process_id + '_' + dbo.bom_item_oper_link.oper_id AS process_id_oper_id, dbo.bom_item.parent_item_id, dbo.bom_item.ver_id, 
                         dbo.bom_item.bom_pos, dbo.bom_item.item_id AS item_id, dbo.bom_item_oper_link.oper_id, dbo.bom_item_oper_link.qty_per_parent_item, dbo.bom_item_oper_link.process_id, 
                         CASE WHEN dbo.bom_item.bom_pos > 0 THEN 'Consume' ELSE 'Produce' END AS material_use, ISNULL(dbo.bom_item.spare1, 'False') AS release_holding_tank, dbo.bom_item_oper_link.mod_id
FROM            dbo.bom_item INNER JOIN
                         dbo.bom_item_oper_link ON dbo.bom_item.parent_item_id = dbo.bom_item_oper_link.parent_item_id AND dbo.bom_item.ver_id = dbo.bom_item_oper_link.ver_id AND 
                         dbo.bom_item.bom_pos = dbo.bom_item_oper_link.bom_pos

GO
/****** Object:  View [dbo].[Simio_Opers_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Opers_ISA95_View]
AS
SELECT DISTINCT 
                  dbo.oper.process_id + '_' + dbo.oper.oper_id + '_' + dbo.bom_item_oper_link.parent_item_id AS RoutingKey, dbo.bom_item_oper_link.parent_item_id AS MaterialName, dbo.oper.process_id AS Routing, dbo.oper.oper_id AS OperationName, dbo.oper.oper_desc, dbo.oper.def_reject_rate, 
                  dbo.oper.first_oper, dbo.oper.final_oper, dbo.oper.display_seq AS RouteNumber, dbo.oper.check_inv, dbo.oper.sched_to_ent_id, dbo.oper.oper_type, dbo.oper.oper_cost, dbo.oper.row_id, dbo.ent.ent_name AS Sequence, 
                  ISNULL(dbo.oper_ent_link.est_setup_time, 0) AS SetupTime, ISNULL(dbo.oper_ent_link.est_teardown_time, 0) AS est_teardown_time, dbo.oper_ent_link.est_prod_rate AS ProcessTime
FROM     dbo.oper INNER JOIN
                  dbo.oper_ent_link ON dbo.oper.process_id = dbo.oper_ent_link.process_id AND dbo.oper.oper_id = dbo.oper_ent_link.oper_id INNER JOIN
                  dbo.ent ON dbo.oper_ent_link.ent_id = dbo.ent.ent_id INNER JOIN
                  dbo.bom_item_oper_link ON dbo.oper.process_id = dbo.bom_item_oper_link.process_id AND dbo.oper.oper_id = dbo.bom_item_oper_link.oper_id
GO
/****** Object:  View [dbo].[Simio_Opers_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Opers_WWMES_View]
AS
SELECT DISTINCT 
                         dbo.oper.process_id + '_' + dbo.oper.oper_id AS process_id_oper_id, dbo.oper.process_id, dbo.oper.oper_id, dbo.oper.oper_desc, dbo.oper.def_reject_rate, dbo.oper.first_oper, dbo.oper.final_oper, 
                         dbo.oper.display_seq, dbo.oper.check_inv, dbo.oper.sched_to_ent_id, dbo.oper.oper_type, dbo.oper.oper_cost, dbo.oper.row_id, dbo.ent.ent_name, ISNULL(dbo.oper_ent_link.est_setup_time, 0) 
                         AS est_setup_time, ISNULL(dbo.oper_ent_link.est_teardown_time, 0) AS est_teardown_time, dbo.oper_ent_link.est_prod_rate
FROM            dbo.oper INNER JOIN
                         dbo.oper_ent_link ON dbo.oper.process_id = dbo.oper_ent_link.process_id AND dbo.oper.oper_id = dbo.oper_ent_link.oper_id INNER JOIN
                         dbo.ent ON dbo.oper_ent_link.ent_id = dbo.ent.ent_id

GO
/****** Object:  View [dbo].[Simio_Processes_MixTankFill_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Processes_MixTankFill_View]
AS
SELECT        process_id AS Routing, process_class_id, process_ver_id, process_desc, process_level, process_status, row_id, mod_id
FROM            dbo.process
GO
/****** Object:  View [dbo].[Simio_Processes_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Processes_WWMES_View]
AS
SELECT        process_id, process_class_id, process_ver_id, process_desc, process_level, process_status, row_id, mod_id
FROM            dbo.process


GO
/****** Object:  View [dbo].[Simio_Routing_Destinations_ISA95_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Simio_Routing_Destinations_ISA95_View]
AS
SELECT        dbo.ent.ent_name AS ResourceName, 'Input@' + ent_1.ent_name AS Node
FROM            dbo.ent INNER JOIN
                         dbo.ent AS ent_1 ON dbo.ent.ent_id = ent_1.parent_ent_id
WHERE        (dbo.ent.can_sched_jobs = 1) OR
                         (dbo.ent.can_run_jobs = 1)
GO
/****** Object:  View [dbo].[Simio_Routing_Destinations_WWMES_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Routing_Destinations_WWMES_View]
AS
SELECT dbo.ent.ent_name, 'Input@' + ent_1.ent_name AS node
FROM  dbo.ent INNER JOIN
         dbo.ent AS ent_1 ON dbo.ent.ent_id = ent_1.parent_ent_id
WHERE (dbo.ent.can_sched_jobs = 1) OR
         (dbo.ent.can_run_jobs = 1)


GO
/****** Object:  View [dbo].[Simio_Util_Exec_View]    Script Date: 11/9/2020 3:03:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Simio_Util_Exec_View]
AS
SELECT     dbo.ent.ent_name, dbo.util_exec.cur_reas_start_local AS event_time_local, DATEADD(minute, dbo.util_reas.standard_time, dbo.util_exec.cur_reas_start_local) AS event_end_time, 'Downtime' AS reas_desc, dbo.util_reas.standard_time, dbo.util_exec.cur_state_cd, 
                  dbo.util_exec.cur_log_id, dbo.util_reas.reas_cd, dbo.ent.ent_id
FROM        dbo.util_exec INNER JOIN
                  dbo.ent ON dbo.util_exec.ent_id = dbo.ent.ent_id INNER JOIN
                  dbo.util_reas ON dbo.util_exec.cur_reas_cd = dbo.util_reas.reas_cd
WHERE     (dbo.util_exec.cur_state_cd IN (0, 4)) AND (DATEADD(minute, dbo.util_reas.standard_time, dbo.util_exec.cur_reas_start_local) > GETDATE())
GO
