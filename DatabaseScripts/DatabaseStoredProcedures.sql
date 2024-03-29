/****** Object:  StoredProcedure [dbo].[sp_Simio_Ents_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Simio_Ents_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Ents_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	
	insert into #temp (EntId, ResourceName, Description, ObjectType, XLocation, ZLocation, DisplayCategory)
	values (0, 'WOCreate', 'Work Order Create', 'SchedSource', '0', '0', '')

	
	insert into #temp (EntId, ResourceName, Description, ObjectType, XLocation, ZLocation, DisplayCategory)
	values (100, 'WOShip', 'Work Order Ship', 'SchedSink', '135', '0', '')


	select * 
	from #temp
	order by EntId


END



GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Ents_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Simio_Ents_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select ent_id, ent_name, description, object_type, x_location, z_location, parent_ent_name
	into #temp
	from Simio_Ents_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	
	insert into #temp (ent_id, ent_name, description, object_type, x_location, z_location, parent_ent_name)
	values (0, 'WOCreate', 'Work Order Create', 'MESSource', '0', '0', '')

	
	insert into #temp (ent_id, ent_name, description, object_type, x_location, z_location, parent_ent_name)
	values (100, 'WOShip', 'Work Order Ship', 'MESSink', '135', '0', '')


	select * 
	from #temp
	order by ent_id


END



GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Item_Boms_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_Simio_Item_Boms_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Item_Boms_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Item_Boms_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Item_Boms_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Item_Boms_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Item_Inv_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Simio_Item_Inv_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Item_Inv_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Item_Inv_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Item_Inv_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Item_Inv_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Items_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Items_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Items_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Items_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Items_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Items_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Job_Boms_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Simio_Job_Boms_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Job_Boms_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	select wo_id_oper_id_seq_no as RoutingKey,
	item_id as ComponentMaterial,
	qty_per_parent_item as RequiredQuantity,
	def_lot_no as LotId,
	material_use as MaterialUse
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Job_Boms_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Job_Boms_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Job_Boms_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Job_UpdateSchedule]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Simio_Job_UpdateSchedule]
(
	@wo_id nvarchar(40) ,
	@oper_id nvarchar(40) ,
	@seq_no int ,
	@target_sched_ent_id int,
	@sched_start_time_local datetime,
	@sched_start_time_tz INT32 = NULL,
	@sched_finish_time_local datetime,
	@sched_finish_time_tz INT32 = NULL
)

AS

BEGIN

	SET @sched_start_time_tz		= dbo.fn_TZ_ValidateOffset(@sched_start_time_tz)
	SET @sched_start_time_local		= dbo.fn_TZ_ValidateLocalDate(@sched_start_time_local, @sched_start_time_tz)
	SET @sched_finish_time_tz		= dbo.fn_TZ_ValidateOffset(@sched_finish_time_tz)
	SET @sched_finish_time_local	= dbo.fn_TZ_ValidateLocalDate(@sched_finish_time_local, @sched_finish_time_tz)

  UPDATE job
  SET	target_sched_ent_id = @target_sched_ent_id,
		sched_start_time_utc = DATEADD( mi, - @sched_start_time_tz, @sched_start_time_local ), -- Added 07/25/2007
		sched_start_time_local = @sched_start_time_local, -- Added 07/25/2007
		sched_finish_time_utc = DATEADD( mi, - @sched_finish_time_tz, @sched_finish_time_local ), -- Added 07/25/2007
		sched_finish_time_local = @sched_finish_time_local
  WHERE (wo_id = @wo_id AND
        oper_id = @oper_id AND
        seq_no = @seq_no )  

END
GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Jobs_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_Simio_Jobs_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select * 
	into #temp
	from Simio_Jobs_ISA95_View
	
	insert into #temp (wo_id_oper_id_seq_no, ent_name, wo_id, oper_id, seq_no, act_finish_time_local, act_finish_time_utc,
	act_start_time_local,act_start_time_utc,sched_finish_time_local_mes, sched_finish_time_utc_mes,
	sched_start_time_local_mes, sched_start_time_utc_mes, state_cd, qty_prod, qty_reqd, est_prod_rate, ent_id, display_seq, row_id,
	est_setup_time, est_teardown_time, job_cost, first_job)
	select wo_id + '_WOShip_0', 'WOShip', wo_id, 'WOShip', 0, '1999-12-31 00:00:00.000', '1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000', 
	0, 0, 0, 0, 0, 100, 10000, 0, 0, 0, 0
	from Simio_Work_Orders_ISA95_View

   select wo_id_oper_id_seq_no as RoutingKey,
     ent_name as Sequence,
	 wo_id as OrderId,
	 display_seq as OperationNumber,
	 est_setup_time as SetupTime,
	 est_prod_rate as ProcessTime,
	 run_ent_name as CurrentResource,
	 qty_prod as CompletedQuantity
	from #temp
	order by wo_id, row_id

END



GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Jobs_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_Simio_Jobs_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select * 
	into #temp
	from Simio_Jobs_WWMES_View
	
	insert into #temp (wo_id_oper_id_seq_no, ent_name, wo_id, oper_id, seq_no, act_finish_time_local, act_finish_time_utc,
	act_start_time_local,act_start_time_utc,sched_finish_time_local_mes, sched_finish_time_utc_mes,
	sched_start_time_local_mes, sched_start_time_utc_mes, state_cd, qty_prod, qty_reqd, est_prod_rate, ent_id, display_seq, row_id,
	est_setup_time, est_teardown_time, job_cost, first_job)
	select wo_id + '_WOShip_0', 'WOShip', wo_id, 'WOShip', 0, '1999-12-31 00:00:00.000', '1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000',
	'1999-12-31 00:00:00.000','1999-12-31 00:00:00.000', 
	0, 0, 0, 0, 0, 100, 10000, 0, 0, 0, 0
	from Simio_Work_Orders_WWMES_View

	select * 
	from #temp
	order by wo_id, row_id

END



GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Opers_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[sp_Simio_Opers_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select * 
	into #temp
	from Simio_Opers_ISA95_View
	
	insert into #temp (RoutingKey, MaterialName, Sequence, Routing, OperationName, oper_desc, ProcessTime, RouteNumber, row_id,
	SetupTime, est_teardown_time, first_oper, final_oper, check_inv, def_reject_rate, oper_cost )
	select distinct process_id + '_WOShip_' + parent_item_id, parent_item_id, 'WOShip', process_id, 'WOShip', 'WOShip', 0, 100, 10000, 0, 0, 0, 1, 0, 0, 0
	from bom_item_oper_link
	

	select * 
	from #temp
	order by Routing, RouteNumber

END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Opers_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[sp_Simio_Opers_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select * 
	into #temp
	from Simio_Opers_WWMES_View
	
	insert into #temp (process_id_oper_id, ent_name, process_id, oper_id, oper_desc, est_prod_rate, display_seq, row_id,
	est_setup_time, est_teardown_time, first_oper, final_oper, check_inv, def_reject_rate, oper_cost )
	select process_id + '_WOShip', 'WOShip', process_id, 'WOShip', 'WOShip', 0, 100, 10000, 0, 0, 0, 1, 0, 0, 0
	from Simio_Processes_WWMES_View
	

	select * 
	from #temp
	order by process_id, display_seq

END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Processes_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Processes_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Processes_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Routing_Destinations_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_Simio_Routing_Destinations_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Routing_Destinations_ISA95_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Routing_Destinations_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Simio_Routing_Destinations_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Routing_Destinations_WWMES_View

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END




GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Update_WO_Dates_ISA95]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Simio_Update_WO_Dates_ISA95] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @days int
	DECLARE @minReleaseTimeLocal datetime

	SELECT @minReleaseTimeLocal = MIN(release_time_local)
	from Simio_Work_Orders_ISA95_View

	SET @days = DateDiff(DAY,@minReleaseTimeLocal, GETDATE());

	if @days != 0
	BEGIN
		update wo set [release_time_utc] = [release_time_utc] + @days
		  ,[release_time_local] = [release_time_local] + @days
		  ,[req_finish_time_utc] = [req_finish_time_utc] + @days
		  ,[req_finish_time_local] = [req_finish_time_local] + @days


		update job set latest_start_time_utc = wo.release_time_utc
		  , latest_start_time_local = wo.release_time_local
		  , req_finish_time_utc = wo.req_finish_time_utc
		  , req_finish_time_local = wo.req_finish_time_local
		from wo
		where wo.wo_id = job.wo_id
	END

	select wo_id as OrderId,
	item_id as MaterialName,
	req_qty as Quantity,
	release_time_local as ReleaseDate,
	req_finish_time_local as DueDate,
	wo_priority as Priority
	from Simio_Work_Orders_ISA95_View
	order by wo_id

END
GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Update_WO_Dates_WWMES]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Simio_Update_WO_Dates_WWMES] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @days int
	DECLARE @minReleaseTimeLocal datetime

	SELECT @minReleaseTimeLocal = MIN(release_time_local)
	from Simio_Work_Orders_WWMES_View

	SET @days = DateDiff(DAY,@minReleaseTimeLocal, GETDATE());

	if @days != 0
	BEGIN
		update wo set [release_time_utc] = [release_time_utc] + @days
		  ,[release_time_local] = [release_time_local] + @days
		  ,[req_finish_time_utc] = [req_finish_time_utc] + @days
		  ,[req_finish_time_local] = [req_finish_time_local] + @days


		update job set latest_start_time_utc = wo.release_time_utc
		  , latest_start_time_local = wo.release_time_local
		  , req_finish_time_utc = wo.req_finish_time_utc
		  , req_finish_time_local = wo.req_finish_time_local
		from wo
		where wo.wo_id = job.wo_id
	END

	select * from Simio_Work_Orders_WWMES_View

END

GO
/****** Object:  StoredProcedure [dbo].[sp_Simio_Util_Exec]    Script Date: 11/9/2020 3:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_Simio_Util_Exec] AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select *
	into #temp
	from Simio_Util_Exec_View

	IF @@ROWCOUNT = 0
	begin

		insert into #temp (ent_id, ent_name, event_time_local, event_end_time, reas_desc, reas_cd)
		values (1, 'Filling1', '9/3/2020 7:30:13 AM', '9/3/2020 11:30:14 AM', 'Downtime', 1) 

	end

	--SET IDENTITY_INSERT #temp ON;
	select * 
	from #temp


END
GO
