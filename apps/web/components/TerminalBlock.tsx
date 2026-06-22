export function TerminalBlock({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="terminal">
      <div className="terminal-bar">{title}</div>
      <pre className="terminal-body">{children}</pre>
    </div>
  );
}
