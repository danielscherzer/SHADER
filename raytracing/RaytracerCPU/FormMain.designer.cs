namespace Raytracer
{
	partial class FormMain
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.pictureBox = new System.Windows.Forms.PictureBox();
			this.backgroundWorker = new System.ComponentModel.BackgroundWorker();
			this.progressBar = new System.Windows.Forms.ProgressBar();
			this.saveFileDialog = new System.Windows.Forms.SaveFileDialog();
			this.menuItemTrace = new System.Windows.Forms.ToolStripMenuItem();
			this.menuItemSave = new System.Windows.Forms.ToolStripMenuItem();
			this.menuItemPrevious = new System.Windows.Forms.ToolStripMenuItem();
			this.menuItemNext = new System.Windows.Forms.ToolStripMenuItem();
			this.menuStrip = new System.Windows.Forms.MenuStrip();
			this.menuItemOptions = new System.Windows.Forms.ToolStripMenuItem();
			this.comboBoxMulti = new System.Windows.Forms.ToolStripComboBox();
			((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
			this.menuStrip.SuspendLayout();
			this.SuspendLayout();
			// 
			// pictureBox
			// 
			this.pictureBox.Dock = System.Windows.Forms.DockStyle.Fill;
			this.pictureBox.Location = new System.Drawing.Point(0, 25);
			this.pictureBox.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
			this.pictureBox.Name = "pictureBox";
			this.pictureBox.Size = new System.Drawing.Size(537, 510);
			this.pictureBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
			this.pictureBox.TabIndex = 0;
			this.pictureBox.TabStop = false;
			this.pictureBox.MouseClick += new System.Windows.Forms.MouseEventHandler(this.PictureBox_MouseClick);
			// 
			// backgroundWorker
			// 
			this.backgroundWorker.WorkerReportsProgress = true;
			this.backgroundWorker.WorkerSupportsCancellation = true;
			this.backgroundWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.BackgroundWorker_DoWork);
			this.backgroundWorker.ProgressChanged += new System.ComponentModel.ProgressChangedEventHandler(this.BackgroundWorker_ProgressChanged);
			// 
			// progressBar
			// 
			this.progressBar.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
			this.progressBar.Location = new System.Drawing.Point(332, 8);
			this.progressBar.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
			this.progressBar.Name = "progressBar";
			this.progressBar.Size = new System.Drawing.Size(188, 20);
			this.progressBar.TabIndex = 2;
			// 
			// saveFileDialog
			// 
			this.saveFileDialog.DefaultExt = "png";
			this.saveFileDialog.Filter = "PNG|*.png|Bitmap|*.bmp|JPG|*.jpg";
			this.saveFileDialog.Title = "Save Image";
			// 
			// menuItemTrace
			// 
			this.menuItemTrace.Name = "menuItemTrace";
			this.menuItemTrace.ShortcutKeys = System.Windows.Forms.Keys.F9;
			this.menuItemTrace.Size = new System.Drawing.Size(47, 19);
			this.menuItemTrace.Text = "Trace";
			this.menuItemTrace.Click += new System.EventHandler(this.MenuItemTrace_Click);
			// 
			// menuItemSave
			// 
			this.menuItemSave.Name = "menuItemSave";
			this.menuItemSave.Size = new System.Drawing.Size(43, 19);
			this.menuItemSave.Text = "Save";
			this.menuItemSave.Click += new System.EventHandler(this.MenuItemSave_Click);
			// 
			// menuItemPrevious
			// 
			this.menuItemPrevious.Name = "menuItemPrevious";
			this.menuItemPrevious.ShortcutKeys = System.Windows.Forms.Keys.F7;
			this.menuItemPrevious.Size = new System.Drawing.Size(27, 19);
			this.menuItemPrevious.Text = "<";
			this.menuItemPrevious.Click += new System.EventHandler(this.MenuItemPrevious_Click);
			// 
			// menuItemNext
			// 
			this.menuItemNext.Name = "menuItemNext";
			this.menuItemNext.ShortcutKeys = System.Windows.Forms.Keys.F8;
			this.menuItemNext.Size = new System.Drawing.Size(27, 19);
			this.menuItemNext.Text = ">";
			this.menuItemNext.Click += new System.EventHandler(this.MenuItemNext_Click);
			// 
			// menuStrip
			// 
			this.menuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuItemOptions,
            this.menuItemTrace,
            this.menuItemSave,
            this.menuItemPrevious,
            this.menuItemNext});
			this.menuStrip.Location = new System.Drawing.Point(0, 0);
			this.menuStrip.Name = "menuStrip";
			this.menuStrip.Padding = new System.Windows.Forms.Padding(9, 3, 0, 3);
			this.menuStrip.Size = new System.Drawing.Size(537, 25);
			this.menuStrip.TabIndex = 1;
			this.menuStrip.Text = "menuStrip1";
			// 
			// menuItemOptions
			// 
			this.menuItemOptions.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.comboBoxMulti});
			this.menuItemOptions.Name = "menuItemOptions";
			this.menuItemOptions.Size = new System.Drawing.Size(61, 19);
			this.menuItemOptions.Text = "Options";
			// 
			// comboBoxMulti
			// 
			this.comboBoxMulti.Items.AddRange(new object[] {
            "1",
            "4",
            "9",
            "16",
            "25",
            "36",
            "49",
            "64",
            "81",
            "100"});
			this.comboBoxMulti.MaxLength = 3;
			this.comboBoxMulti.Name = "comboBoxMulti";
			this.comboBoxMulti.Size = new System.Drawing.Size(121, 23);
			this.comboBoxMulti.Text = "1";
			// 
			// FormMain
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(537, 535);
			this.Controls.Add(this.progressBar);
			this.Controls.Add(this.pictureBox);
			this.Controls.Add(this.menuStrip);
			this.MainMenuStrip = this.menuStrip;
			this.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
			this.Name = "FormMain";
			this.Text = "Ray Tracer";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormMain_FormClosing);
			this.Load += new System.EventHandler(this.FormMain_Load);
			this.Shown += new System.EventHandler(this.FormMain_Shown);
			((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
			this.menuStrip.ResumeLayout(false);
			this.menuStrip.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.PictureBox pictureBox;
		private System.ComponentModel.BackgroundWorker backgroundWorker;
		private System.Windows.Forms.ProgressBar progressBar;
		private System.Windows.Forms.SaveFileDialog saveFileDialog;
		private System.Windows.Forms.ToolStripMenuItem menuItemTrace;
		private System.Windows.Forms.ToolStripMenuItem menuItemSave;
		private System.Windows.Forms.ToolStripMenuItem menuItemPrevious;
		private System.Windows.Forms.ToolStripMenuItem menuItemNext;
		private System.Windows.Forms.MenuStrip menuStrip;
		private System.Windows.Forms.ToolStripMenuItem menuItemOptions;
		private System.Windows.Forms.ToolStripComboBox comboBoxMulti;
	}
}

